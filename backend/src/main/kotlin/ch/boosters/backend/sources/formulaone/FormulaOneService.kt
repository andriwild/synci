package ch.boosters.backend.sources.formulaone

import arrow.core.Either
import arrow.core.raise.either
import ch.boosters.backend.errorhandling.SynciEither
import org.springframework.stereotype.Service
import org.springframework.web.reactive.function.client.ExchangeStrategies
import org.springframework.web.reactive.function.client.WebClient
import reactor.core.publisher.Mono
import java.time.LocalDateTime


@Service
class FormulaOneService(
    private val webClientBuilder: WebClient.Builder,
    private val formulaOneSerializer: FormulaOneSerializer,
    private val formulaOneConfig: FormulaOneConfig,
    private val formulaOneRepository: FormulaOneRepository,
) {

    fun update(): SynciEither<Unit> = either {
        val lastSync = formulaOneRepository.lastSyncTime().bind()

        if(lastSync != null && lastSync.isAfter(LocalDateTime.now().minusDays(1))) {
            return Either.Right(Unit)
        }

        val baseUrl = formulaOneConfig.url


        // TODO: #11 introduce proper logging
        println("Fetching races from F1 API at ${LocalDateTime.now()}")
        val url = "$baseUrl/current"
        // TODO: #11 introduce proper logging
        println("Fetching races from SwissSki at ${url}")
        val exchangeStrategies = ExchangeStrategies.builder()
            .codecs { configurer ->
                configurer.defaultCodecs().maxInMemorySize(10 * 1024 * 1024) // 10 MB
            }
            .build()

        val response = eventResponse(exchangeStrategies, url)
        val formulaOneEvents = response.map (formulaOneSerializer::parseResponse)
        formulaOneRepository.deleteData()
        formulaOneEvents.map(formulaOneRepository::storeEvents).block()

        formulaOneRepository.storeSyncTime()
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