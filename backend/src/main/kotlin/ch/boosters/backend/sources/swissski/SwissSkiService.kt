package ch.boosters.backend.sources.swissski

import org.springframework.stereotype.Service
import org.springframework.web.reactive.function.client.ExchangeStrategies
import org.springframework.web.reactive.function.client.WebClient
import reactor.core.publisher.Mono
import java.time.LocalDateTime


@Service
class SwissSkiService(
    private val webClientBuilder: WebClient.Builder,
    private val swissSkiSerializer: SwissSkiSerializer,
    private val swissSkiConfig: SwissSkiConfig,
    private val swissSkiRepository: SwissSkiRepository,
) {

    fun updateRaces() {
        val baseUrl = swissSkiConfig.url

        // TODO: #11 introduce proper logging
        println("Fetching races from SwissSki at ${LocalDateTime.now()}")
        val sport = swissSkiConfig.sport
        val url = "$baseUrl/web_race?page_size=1000&order_by=racedate&racedate__gt=2024-10-11&sport=$sport"
        // TODO: #11 introduce proper logging
        println("Fetching races from SwissSki at ${url}")
        val exchangeStrategies = ExchangeStrategies.builder()
            .codecs { configurer ->
                configurer.defaultCodecs().maxInMemorySize(10 * 1024 * 1024) // 10 MB
            }
            .build()

        val response = eventResponse(exchangeStrategies, url)
        response.map (swissSkiSerializer::parseResponse)
            .map(swissSkiRepository::storeEvents)
            .block()
    }

    private fun eventResponse(exchangeStrategies: ExchangeStrategies, url: String): Mono<String> {
        return try {
            webClientBuilder
                .exchangeStrategies(exchangeStrategies)
                .build()
                .get()
                .uri(url)
                .retrieve()
                .bodyToMono(String::class.java)
        } catch (e: Exception) {
            // TODO: #11 introduce proper logging
            println("Error fetching swiss ski events overview: $e")
            Mono.empty()
        }
    }
}