package ch.boosters.backend.sources.swissski

import ch.boosters.backend.sources.SourceConfig
import org.springframework.stereotype.Service
import org.springframework.web.reactive.function.client.ExchangeStrategies
import org.springframework.web.reactive.function.client.WebClient
import reactor.core.publisher.Mono
import java.time.LocalDateTime


@Service
class SwissSkiService(
    private val webClientBuilder: WebClient.Builder,
    private val serializer: RaceSerializer,
    private val sourceConfig: SourceConfig,
    private val swissSkiRepository: SwissSkiRepository
) {

    fun getSubcategoriesOfCategory(category: String): List<String> {
        return swissSkiRepository.getSubcategoryOfCategory(category)
    }

    fun updateRaces() {
        val baseUrl = sourceConfig.swissSki.url

        println("Fetching races from SwissSki at ${LocalDateTime.now()}")
        val sport = sourceConfig.swissSki.sport
        val url = "$baseUrl/web_race?page_size=1000&order_by=racedate&racedate__gt=2024-10-11&sport=$sport"
        println("Fetching races from SwissSki at ${url}")
        val exchangeStrategies = ExchangeStrategies.builder()
            .codecs { configurer ->
                configurer.defaultCodecs().maxInMemorySize(10 * 1024 * 1024) // 10 MB
            }
            .build()

        println("checkpoint")
        val response= eventResponse(exchangeStrategies, url)
        response.map (serializer::parseResponse)
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
            println("Error fetching swiss ski events overview: $e")
            Mono.empty()
        }
    }
}
