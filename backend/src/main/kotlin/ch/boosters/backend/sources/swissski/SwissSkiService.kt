package ch.boosters.backend.sources.swissski

import arrow.core.Either
import arrow.core.raise.either
import ch.boosters.backend.errorhandling.SynciEither
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

    fun update(): SynciEither<Unit> = either {
        val lastSync = swissSkiRepository.lastSyncTime().bind()

        if(lastSync != null && lastSync.isAfter(LocalDateTime.now().minusDays(1))) {
            return Either.Right(Unit)
        }

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

        swissSkiRepository.storeSyncTime()
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