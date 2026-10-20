package ch.boosters.backend.sources.nflverse

import arrow.core.Either
import arrow.core.raise.either
import arrow.core.raise.ensure
import ch.boosters.backend.config.SYNC_INTERVAL
import ch.boosters.backend.data.sport.SportsRepository
import ch.boosters.backend.data.team.teamSports.TeamSportsRepository
import ch.boosters.backend.errorhandling.ElementNotFound
import ch.boosters.backend.errorhandling.ExternalSourceError
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.backend.sources.common.SourceSyncRepository
import ch.boosters.backend.sources.common.futureOnly
import ch.boosters.backend.sources.nflverse.model.NflGame
import org.springframework.http.client.reactive.ReactorClientHttpConnector
import org.springframework.stereotype.Service
import org.springframework.web.reactive.function.client.ExchangeStrategies
import org.springframework.web.reactive.function.client.WebClient
import reactor.netty.http.client.HttpClient
import java.io.ByteArrayInputStream
import java.time.LocalDateTime
import java.util.zip.GZIPInputStream

/**
 * Loads the NFL schedule from the nflverse games.csv and stores the upcoming games of the
 * current season as team events below NFL_REGULAR_SEASON / NFL_PLAYOFFS.
 */
@Service
class NflverseService(
    private val webClientBuilder: WebClient.Builder,
    private val config: NflverseConfig,
    private val syncRepository: SourceSyncRepository,
    private val sportsRepository: SportsRepository,
    private val teamSportsRepository: TeamSportsRepository,
) {
    private val webClient by lazy {
        val strategies = ExchangeStrategies.builder()
            .codecs { it.defaultCodecs().maxInMemorySize(16 * 1024 * 1024) }
            .build()
        // GitHub release assets answer with a 302 to their CDN
        webClientBuilder
            .clientConnector(ReactorClientHttpConnector(HttpClient.create().followRedirect(true)))
            .exchangeStrategies(strategies)
            .build()
    }

    fun update(): SynciEither<Unit> = either {
        val sourceName = config.name
        ensure(sourceName != null) { ElementNotFound("Missing source name in nflverse configuration") }
        val sourceId = syncRepository.sourceIdByName(sourceName).bind()

        val lastSync = syncRepository.lastSyncTime(sourceId).bind()
        // shorter than interval, otherwise every second run is skipped
        if (lastSync != null && lastSync.isAfter(LocalDateTime.now().minus(SYNC_INTERVAL).plusHours(1))) {
            return Either.Right(Unit)
        }

        val games = NflverseCsvParser.parse(download().bind())
        val season = NflGameMapper.currentSeason(games, config)
        ensure(season != null) { ExternalSourceError("nflverse schedule contains no games") }
        val seasonGames = games.filter { it.season == season }
        val logos = downloadLogos()
        println("nflverse: ${seasonGames.size} games in season $season (${games.size} in file)")

        seasonGames
            .groupBy { config.sportKeyFor(it.gameType) }
            .forEach { (sportKey, gamesOfType) ->
                if (sportKey == null) {
                    println("nflverse: skipping ${gamesOfType.size} games with unknown game_type '${gamesOfType.first().gameType}'")
                } else {
                    store(sourceId, sportKey, gamesOfType, logos).bind()
                }
            }
        syncRepository.storeSyncTime(sourceId).bind()
    }

    private fun store(sourceId: Int, sportKey: String, games: List<NflGame>, logos: Map<String, String>): SynciEither<Unit> = either {
        val sportId = sportsRepository.sportIdByName(sportKey).bind()
        ensure(sportId != null) { ElementNotFound("While updating nflverse sport '$sportKey' not found") }

        val namesById = games.associate { it.gameId to NflGameMapper.eventName(it, config) }
        val events = games.mapNotNull { NflGameMapper.toTeamEvent(it, config) }.futureOnly()
        val teams = NflGameMapper.teamsOf(events, sourceId, logos)
        println("nflverse: $sportKey -> ${events.size} upcoming games, ${teams.size} teams")

        syncRepository.upsertTeams(teams).bind()
        teamSportsRepository.upsertTeams(teams, sportId).bind()
        syncRepository.upsertTeamEvents(sourceId, sportId, events) { event ->
            namesById[event.id] ?: "${event.homeName} - ${event.awayName}"
        }.bind()
    }

    /** Team logos are a nice-to-have: if the file cannot be loaded, the schedule is stored without them. */
    private fun downloadLogos(): Map<String, String> {
        val url = config.teamsUrl ?: return emptyMap()
        return try {
            println("Fetching from $url")
            val csv = webClient.get().uri(url).retrieve().bodyToMono(String::class.java).block() ?: return emptyMap()
            NflverseCsvParser.parseLogos(csv)
        } catch (e: Exception) {
            println("nflverse: team logos could not be loaded, continuing without: ${e.message}")
            emptyMap()
        }
    }

    /** Tries the primary url first, then every fallback; .gz urls are decompressed. */
    private fun download(): SynciEither<String> {
        val urls = listOfNotNull(config.url) + config.fallbackUrls
        val failures = mutableListOf<String>()
        for (url in urls) {
            try {
                println("Fetching from $url")
                val bytes = webClient.get().uri(url).retrieve().bodyToMono(ByteArray::class.java).block()
                    ?: throw IllegalStateException("empty response")
                return Either.Right(decode(url, bytes))
            } catch (e: Exception) {
                failures += "$url: ${e.message}"
            }
        }
        return Either.Left(ExternalSourceError("nflverse schedule could not be loaded: ${failures.joinToString("; ")}"))
    }

    private fun decode(url: String, bytes: ByteArray): String =
        if (url.endsWith(".gz")) GZIPInputStream(ByteArrayInputStream(bytes)).use { it.readBytes().decodeToString() }
        else bytes.decodeToString()
}
