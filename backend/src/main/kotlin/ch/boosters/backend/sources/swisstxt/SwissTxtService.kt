package ch.boosters.backend.sources.swisstxt

import arrow.core.Either
import arrow.core.raise.either
import arrow.core.raise.ensure
import ch.boosters.backend.data.sport.SportsRepository
import ch.boosters.backend.data.team.teamSports.TeamSportsRepository
import ch.boosters.backend.errorhandling.ElementNotFound
import ch.boosters.backend.errorhandling.SynciEither
import org.springframework.stereotype.Service
import org.springframework.web.reactive.function.client.ExchangeStrategies
import org.springframework.web.reactive.function.client.WebClient
import reactor.core.publisher.Mono
import java.time.LocalDateTime

@Service
class SwissTxtService(
    private val webClientBuilder: WebClient.Builder,
    private val swissTxtConfig: SwissTxtConfig,
    private val swissTxtRepository: SwissTxtRepository,
    private val serializer: EventSerializer,
    private val sportsRepository: SportsRepository,
    private val teamSportsRepository: TeamSportsRepository,
    ) {

    fun update(): SynciEither<Unit> = either{

        val lastSync = swissTxtRepository.lastSyncTime().bind()

//        if(lastSync != null && lastSync.isAfter(LocalDateTime.now().minusDays(1))) {
//            return Either.Right(Unit)
//        }

        val sport = swissTxtConfig.sport
        val sourceId = swissTxtConfig.id
        ensure(sourceId != null) { ElementNotFound("Missing source ID in SwissTxt configuration")}

        val sportData = sport.map { Pair(it.key, it.leagues) } // List(Pair(SOCCER, [...]))

        // TODO: refactor: we need to delete the data only right before saving
        swissTxtRepository.deleteSwissTxtData()

        sportData.forEach { (sportKey, leagues) ->
            println("Fetching ${leagues.size} leagues from SwissTxt $sportKey")

            leagues.forEach{ league ->
                val sportId = sportsRepository.sportIdByName(league.name).bind()
                ensure (sportId != null){ ElementNotFound("While updating SwissTxt $sportId not found") }

                fetchEvents(league.id)
                    .map(serializer::parseResponse)
                    .map{ (events, teams) ->
                        // TODO: do not return Unit
                        val resTeams  = swissTxtRepository.storeTeams(teams)
                        val resSport = teamSportsRepository.storeTeams(teams, sourceId, sportId)
                        swissTxtRepository.storeEvents(events, league.name)
                        resTeams
                    }.block()

            }
            println("\nDone!")

        }



        swissTxtRepository.storeSyncTime()
    }

    private fun fetchEvents(leagueId: String): Mono<String> {

        val baseUrl = swissTxtConfig.url

        val url = "$baseUrl/eventItems?phaseIds=$leagueId&lang=de"
        println("fetching from $url")
        val exchangeStrategies = ExchangeStrategies.builder()
            .codecs { configurer ->
                configurer.defaultCodecs().maxInMemorySize(10 * 1024 * 1024) // 10 MB
            }
            .build()

        val response = leaguesResponse(exchangeStrategies, url)
        return response
    }

    private fun leaguesResponse(exchangeStrategies: ExchangeStrategies, url: String): Mono<String> {
        return try {
            webClientBuilder
                .exchangeStrategies(exchangeStrategies)
                .build()
                .get()
                .uri(url)
                .retrieve()
                .bodyToMono(String::class.java)
        } catch (e: Exception) {
            println("Error fetching league overview: $e")
            Mono.empty()
        }
    }
}