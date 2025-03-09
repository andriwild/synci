package ch.boosters.backend.sources.swisstxt

import arrow.core.Either
import arrow.core.raise.either
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
    ) {

    fun update(): SynciEither<Unit> = either{

        val lastSync = swissTxtRepository.lastSyncTime().bind()

        if(lastSync != null && lastSync.isAfter(LocalDateTime.now().minusDays(1))) {
            return Either.Right(Unit)
        }

        val leagues = swissTxtConfig.leagues
        println("Fetching ${leagues.size} leagues from SwissTxt")

        // TODO: refactor: we need to delete the data only right before saving
        swissTxtRepository.deleteSwissTxtData()
        leagues.forEach{ league ->
            fetchEvents(league.id)
                .map(serializer::parseResponse)
                .map{ (events, teams) ->
                    // TODO: do not return Unit
                    val resTeams  = swissTxtRepository.storeTeams(teams)
                    swissTxtRepository.storeEvents(events, league.name)
                    resTeams
                }.block()

        }
        println("\nDone!")
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