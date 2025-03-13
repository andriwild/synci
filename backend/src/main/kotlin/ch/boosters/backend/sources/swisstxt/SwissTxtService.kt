package ch.boosters.backend.sources.swisstxt

import arrow.core.Either
import arrow.core.raise.either
import arrow.core.raise.ensure
import ch.boosters.backend.data.sport.SportsRepository
import ch.boosters.backend.data.team.Team
import ch.boosters.backend.data.team.teamSports.TeamSportsRepository
import ch.boosters.backend.errorhandling.ElementNotFound
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.backend.sources.swisstxt.model.SwissTxtTeamEvent
import org.springframework.stereotype.Service
import org.springframework.web.reactive.function.client.ExchangeStrategies
import org.springframework.web.reactive.function.client.WebClient
import reactor.core.publisher.Mono
import java.time.LocalDateTime
import java.util.*

@Service
class SwissTxtService(
    private val webClientBuilder: WebClient.Builder,
    private val swissTxtConfig: SwissTxtConfig,
    private val swissTxtRepository: SwissTxtRepository,
    private val serializer: EventSerializer,
    private val sportsRepository: SportsRepository,
    private val teamSportsRepository: TeamSportsRepository,
) {

    fun update(): SynciEither<Unit> = either {
        val lastSync = swissTxtRepository.lastSyncTime().bind()

        if (lastSync != null && lastSync.isAfter(LocalDateTime.now().minusDays(1))) {
            return Either.Right(Unit)
        }
        val sourceId = swissTxtConfig.id
        ensure(sourceId != null) { ElementNotFound("Missing source ID in SwissTxt configuration") }

        swissTxtConfig.sport.forEach {
            println("Fetching ${it.leagues.size} leagues from SwissTxt ${it.key}")
            val leagueEvents = mutableMapOf<SwissTxtLeague, List<SwissTxtTeamEvent>>()
            it.leagues.forEach { league ->
                val events = fetchEventsFromApi(league.id).block()
                ensure(events != null) { ElementNotFound("") }
                leagueEvents[league] = events
            }
            swissTxtRepository.deleteSwissTxtData()
            leagueEvents.forEach{(league, events) -> updateRepositories(sourceId, league, events)}
            println("\nDone!")
        }
        swissTxtRepository.storeSyncTime()
    }

    private fun updateRepositories(
        sourceId: Int,
        league: SwissTxtLeague,
        events: List<SwissTxtTeamEvent>
    ): SynciEither<Pair<IntArray, IntArray>> = either {
        // Retrieve all teams involved in the events (assuming each team appears at least once as the home team)
        val teams = events.map { team -> Team(team.homeId, sourceId, team.homeName) }.distinct()
        val sportId = getSportId(league.name).bind()

        val teamIds = swissTxtRepository.storeTeams(teams).bind()
        val teamSportIds = teamSportsRepository.storeTeams(teams, sportId).bind()
        swissTxtRepository.storeEvents(league.id, events).bind()
        Pair(teamIds, teamSportIds)
    }

    private fun getSportId(leagueName: String): SynciEither<UUID> = either {
        val sportId = sportsRepository.sportIdByName(leagueName).bind()
        ensure(sportId != null) { ElementNotFound("While updating SwissTxt $sportId not found") }
        sportId
    }

    private fun fetchEventsFromApi(leagueId: String): Mono<List<SwissTxtTeamEvent>> {
        val url = "${swissTxtConfig.url}/eventItems?phaseIds=$leagueId&lang=de"
        println("fetching from $url")
        val exchangeStrategies = ExchangeStrategies.builder().codecs { configurer ->
            configurer.defaultCodecs().maxInMemorySize(10 * 1024 * 1024) // 10 MB
        }.build()
        return webClientBuilder.exchangeStrategies(exchangeStrategies).build().get().uri(url).retrieve()
            .bodyToMono(String::class.java)
            .map(serializer::parseResponse)
    }
}