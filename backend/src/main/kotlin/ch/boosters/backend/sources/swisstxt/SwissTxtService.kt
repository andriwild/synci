package ch.boosters.backend.sources.swisstxt

import arrow.core.Either
import arrow.core.raise.Raise
import arrow.core.raise.either
import arrow.core.raise.ensure
import ch.boosters.backend.data.event.model.BaseEvent
import ch.boosters.backend.data.event.model.Event
import ch.boosters.backend.data.event.model.TeamEvent
import ch.boosters.backend.data.sport.SportsRepository
import ch.boosters.backend.data.team.Team
import ch.boosters.backend.data.team.teamSports.TeamSportsRepository
import ch.boosters.backend.errorhandling.ElementNotFound
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.backend.errorhandling.SynciError
import ch.boosters.backend.sources.swisstxt.model.SwissTxtEvent
import ch.boosters.backend.sources.swisstxt.model.SwissTxtLeagueConfig
import ch.boosters.backend.sources.swisstxt.serializers.EventSerializer
import ch.boosters.backend.sources.swisstxt.serializers.LeagueSerializer
import ch.boosters.backend.sources.swisstxt.serializers.TeamEventSerializer
import org.springframework.stereotype.Service
import org.springframework.web.reactive.function.client.ExchangeStrategies
import org.springframework.web.reactive.function.client.WebClient
import reactor.core.publisher.Mono
import java.time.LocalDateTime
import java.util.*
import kotlin.collections.component1
import kotlin.collections.component2
import kotlin.collections.set

@Service
class SwissTxtService(
    private val webClientBuilder: WebClient.Builder,
    private val swissTxtConfig: SwissTxtConfig,
    private val swissTxtRepository: SwissTxtRepository,
    private val teamEventSerializer: TeamEventSerializer,
    private val eventSerializer: EventSerializer,
    private val leagueSerializer: LeagueSerializer,
    private val sportsRepository: SportsRepository,
    private val teamSportsRepository: TeamSportsRepository,
) {
    private val webClient by lazy {
        val exchangeStrategies = ExchangeStrategies.builder()
            .codecs { it.defaultCodecs().maxInMemorySize(10 * 1024 * 1024) }
            .build()
        webClientBuilder.exchangeStrategies(exchangeStrategies).build()
    }

    fun update(): SynciEither<Unit> = either {
        val lastSync = swissTxtRepository.lastSyncTime().bind()

        if (lastSync != null && lastSync.isAfter(LocalDateTime.now().minusDays(1))) {
            return Either.Right(Unit)
        }
        val sourceId = swissTxtConfig.id
        ensure(sourceId != null) { ElementNotFound("Missing source ID in SwissTxt configuration") }


        updateTeamEvents(swissTxtConfig.teamSport, sourceId)
        updateEvents(swissTxtConfig.events, sourceId)
        swissTxtRepository.storeSyncTime()
    }

    fun updateTeamEvents(teamSports: MutableList<SwissTxtTeamSport>, sourceId: Int): SynciEither<Unit> = either {
        val leagueEvents = teamSports.flatMap { teamSport -> fetchAllEventForLeague(teamSport) }
        leagueEvents.forEach { (league, events) -> updateRepositoriesForTeamEvents(sourceId, league, events) }
        println("\nDone!")
    }

    private fun Raise<SynciError>.fetchAllEventForLeague(teamSport: SwissTxtTeamSport): List<Pair<String, List<TeamEvent>>> =
        teamSport.leagues.flatMap { league ->
            val leagueConfig = fetchLeagueConfigFromApi(teamSport.id, league.id).block()
            ensure(leagueConfig != null) { ElementNotFound("") }

            if (leagueConfig.competitorType == "Team") {
                collectLeaguesToFetch(leagueConfig, league).map { (leagueKey, id) ->
                    eventsForLeague(id, teamSport, league, leagueKey).bind()
                }
            } else listOf()
        }

    private fun eventsForLeague(
        id: String,
        teamSport: SwissTxtTeamSport,
        league: SwissTxtSportLeague,
        leagueKey: String
    ): SynciEither<Pair<String, List<TeamEvent>>> = either {
        val events = fetchEventsFromApi(id).block()
        ensure(events != null) { ElementNotFound("Events of ${teamSport.name} - ${league.name} not found") }
        Pair(leagueKey, filterPastEvents(events))
    }

    fun updateEvents(eventSports: List<SwissTxtEventSport>, sourceId: Int): SynciEither<Unit> = either {
        val leagueEvents = mutableMapOf<SwissTxtSportLeague, List<Event>>()
        eventSports.forEach { teamSport ->
            teamSport.disciplines.forEach { discipline ->
                discipline.leagues.forEach { eventLeague ->
                    val event = fetchEventConfigFromApi(discipline.id, eventLeague.id).block()
                    ensure(event != null) { ElementNotFound("Events of ${teamSport.name} - ${eventLeague.name} not found") }
                    leagueEvents[eventLeague] = filterPastEvents(event.events)
                }
            }
        }
        leagueEvents.forEach { (cat, events) -> updateRepositoriesForEvents(sourceId, cat, events) }
        println("\nDone!")
    }

    private fun updateRepositoriesForEvents(
        sourceId: Int,
        cat: SwissTxtSportLeague,
        events: List<Event>
    ): SynciEither<Unit> = either {
        val sportId = getSportId(cat.name).bind()
        swissTxtRepository.upsertEvents(sourceId, sportId, events).bind()
    }

    private fun updateRepositoriesForTeamEvents(
        sourceId: Int,
        leagueName: String,
        events: List<TeamEvent>
    ): SynciEither<Pair<IntArray, IntArray>> = either {
        val teams = events.map { team -> Team(team.homeId, sourceId, team.homeName, team.gender) }.distinct()
        val sportId = getSportId(leagueName).bind()

        val teamIds = swissTxtRepository.upsertTeams(teams).bind()
        val teamSportIds = teamSportsRepository.upsertTeams(teams, sportId).bind()
        swissTxtRepository.upsertEvents(leagueName, events).bind()
        Pair(teamIds, teamSportIds)
    }

    private fun getSportId(leagueName: String): SynciEither<UUID> = either {
        val sportId = sportsRepository.sportIdByName(leagueName).bind()
        ensure(sportId != null) { ElementNotFound("While updating SwissTxt sport '$leagueName' not found") }
        sportId
    }

    private fun <T> fetchFromApi(url: String, parser: (String) -> T): Mono<T> {
        println("Fetching from $url")
        return webClient.get()
            .uri(url)
            .retrieve()
            .bodyToMono(String::class.java)
            .map(parser)
    }

    private fun fetchLeagueConfigFromApi(sportId: String, leagueKey: String): Mono<SwissTxtLeagueConfig> {
        val url = "${swissTxtConfig.url}/${sportId}/${leagueKey}?lang=de"
        return fetchFromApi(url, leagueSerializer::parseResponse)
    }

    private fun fetchEventsFromApi(leagueId: String): Mono<List<TeamEvent>> {
        val url = "${swissTxtConfig.url}/eventItems?phaseIds=$leagueId&lang=de"
        return fetchFromApi(url, teamEventSerializer::parseResponse)
    }

    private fun fetchEventConfigFromApi(sportId: String, leagueKey: String): Mono<SwissTxtEvent> {
        val url = "${swissTxtConfig.url}/${sportId}/${leagueKey}?lang=de"
        return fetchFromApi(url, eventSerializer::parseResponse)
    }

    private fun collectLeaguesToFetch(
        leagueConfig: SwissTxtLeagueConfig,
        league: SwissTxtSportLeague
    ): List<Pair<String, String>> {
        // mapping phase key -> phase id to fetch (e.g. CL_QUALIFICATION_1 -> 1234-123)
        return when {
            league.includeAll -> listOf(Pair(league.name, leagueConfig.phases.joinToString(",")))
            league.phases.isEmpty() -> listOf(Pair(league.name, leagueConfig.id))
            else -> league.phases.zip(leagueConfig.phases)
        }
    }

    private fun <T : BaseEvent> filterPastEvents(events: List<T>): List<T> {
        val now = LocalDateTime.now()
        val futureEvents = events.filter { event -> event.startsOn.isAfter(now) }
        if (futureEvents.isNotEmpty()) {
            println("Filtered ${futureEvents.size} future events (${events.size} total, ${events.size - futureEvents.size} past events filtered out)")
        } else {
            println("No future events found")
        }
        return futureEvents
    }
}