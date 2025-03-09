package ch.boosters.backend.sources.swisstxt

import org.springframework.stereotype.Service
import org.springframework.web.reactive.function.client.ExchangeStrategies
import org.springframework.web.reactive.function.client.WebClient
import reactor.core.publisher.Mono

@Service
class SwissTxtService(
    private val webClientBuilder: WebClient.Builder,
    private val swissTxtConfig: SwissTxtConfig,
    private val swissTxtRepository: SwissTxtRepository,
    private val serializer: EventSerializer,
    ) {

    fun update() {
        val leagues = swissTxtConfig.leagues
        println("Fetching ${leagues.size} leagues from SwissTxt")
        leagues.forEach{ league ->
            fetchEvents(league.id, league.name).block()
        }
        println("\nDone!")
    }

    private fun fetchEvents(leagueId: String, sportId: String): Mono<IntArray> {

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
            .map(serializer::parseResponse)
            .map{ (events, teams) ->
                val resTeams  = swissTxtRepository.storeTeams(teams)
                swissTxtRepository.storeEvents(events, sportId)
                resTeams
            }
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