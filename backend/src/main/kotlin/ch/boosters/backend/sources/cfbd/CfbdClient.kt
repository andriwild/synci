package ch.boosters.backend.sources.cfbd

import arrow.core.Either
import ch.boosters.backend.errorhandling.ExternalSourceError
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.backend.sources.cfbd.model.CfbdGame
import kotlinx.serialization.json.Json
import org.springframework.http.HttpHeaders
import org.springframework.stereotype.Component
import org.springframework.web.reactive.function.client.ExchangeStrategies
import org.springframework.web.reactive.function.client.WebClient
import org.springframework.web.reactive.function.client.WebClientResponseException
import java.net.URI

/** Reads the games of a season from the CollegeFootballData REST API (one call per season). */
@Component
class CfbdClient(
    webClientBuilder: WebClient.Builder,
    private val config: CfbdConfig,
    private val json: Json,
) {
    private val webClient = webClientBuilder
        .exchangeStrategies(
            ExchangeStrategies.builder().codecs { it.defaultCodecs().maxInMemorySize(16 * 1024 * 1024) }.build()
        )
        .build()

    /** Regular season and postseason games of [season] with at least one team of the configured classification. */
    fun games(season: Int): SynciEither<List<CfbdGame>> {
        val uri = URI.create("${config.url.trimEnd('/')}/games?year=$season&seasonType=both&classification=${config.classification}")
        println("Fetching from $uri")
        return try {
            val response = webClient.get()
                .uri(uri)
                .header(HttpHeaders.AUTHORIZATION, "Bearer ${config.token}")
                .retrieve()
                .toEntity(String::class.java)
                .block() ?: return Either.Left(ExternalSourceError("CFBD: empty response for season $season"))
            response.headers.getFirst("X-CallLimit-Remaining")?.let { println("CFBD: $it calls left this month") }
            Either.Right(json.decodeFromString<List<CfbdGame>>(response.body ?: "[]"))
        } catch (e: WebClientResponseException) {
            Either.Left(ExternalSourceError("CFBD ${e.statusCode.value()} for season $season: ${e.responseBodyAsString.take(200)}"))
        } catch (e: Exception) {
            Either.Left(ExternalSourceError("CFBD request for season $season failed: ${e.message}"))
        }
    }
}
