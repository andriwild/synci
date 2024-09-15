package ch.boosters.backend.sources.fotmob

import org.springframework.stereotype.Service
import org.springframework.web.reactive.function.client.ExchangeStrategies
import org.springframework.web.reactive.function.client.WebClient
import reactor.core.publisher.Mono

@Service
class FotMobService(
    private val webClientBuilder: WebClient.Builder
) {

    fun fetchLeagueOverview(leagueId: String): Mono<String> {
        val url = "https://www.fotmob.com/api/leagues?id=$leagueId&tab=overview&type=league"
        val exchangeStrategies = ExchangeStrategies.builder()
            .codecs { configurer ->
                configurer.defaultCodecs().maxInMemorySize(10 * 1024 * 1024) // 10 MB
            }
            .build()

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