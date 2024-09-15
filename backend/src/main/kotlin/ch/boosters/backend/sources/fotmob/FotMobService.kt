package ch.boosters.backend.sources.fotmob

import org.springframework.stereotype.Service
import org.springframework.web.reactive.function.client.ExchangeStrategies
import org.springframework.web.reactive.function.client.WebClient
import reactor.core.publisher.Mono

@Service
class FotMobService(
    private val webClientBuilder: WebClient.Builder,
    private val serializer: LeagueSerializer,
    private val fotMobRepository: FotMobRepository

) {

    fun fetchLeagueOverview(leagueId: String): Mono<IntArray> {
        val url = "https://www.fotmob.com/api/leagues?id=$leagueId&tab=overview&type=league"
        val exchangeStrategies = ExchangeStrategies.builder()
            .codecs { configurer ->
                configurer.defaultCodecs().maxInMemorySize(10 * 1024 * 1024) // 10 MB
            }
            .build()

        val response = leaguesResponse(exchangeStrategies, url)
        return response
            .map(serializer::parseResponse)
            .map{ (events, teams) ->
                val resTeams  = fotMobRepository.storeTeams(teams)
                val resEvents = fotMobRepository.storeEvents(events)
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