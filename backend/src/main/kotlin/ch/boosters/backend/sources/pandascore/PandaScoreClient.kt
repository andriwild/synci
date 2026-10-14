package ch.boosters.backend.sources.pandascore

import arrow.core.Either
import ch.boosters.backend.errorhandling.ExternalSourceError
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.backend.sources.pandascore.model.PandaScoreMatch
import kotlinx.serialization.json.Json
import org.springframework.http.HttpHeaders
import org.springframework.stereotype.Component
import org.springframework.web.reactive.function.client.ExchangeStrategies
import org.springframework.web.reactive.function.client.WebClient
import org.springframework.web.reactive.function.client.WebClientResponseException
import java.net.URI
import java.net.URLEncoder
import java.nio.charset.StandardCharsets

/** Reads upcoming matches per videogame from the PandaScore REST API (free fixtures plan). */
@Component
class PandaScoreClient(
    webClientBuilder: WebClient.Builder,
    private val config: PandaScoreConfig,
    private val json: Json,
) {
    private val webClient = webClientBuilder
        .exchangeStrategies(
            ExchangeStrategies.builder().codecs { it.defaultCodecs().maxInMemorySize(8 * 1024 * 1024) }.build()
        )
        .build()

    /** All upcoming matches of a videogame, page by page until a page is not full. */
    fun upcomingMatches(videogame: String): SynciEither<List<PandaScoreMatch>> {
        val matches = mutableListOf<PandaScoreMatch>()
        var page = 1
        while (true) {
            val result = fetchPage(videogame, page)
            when (result) {
                is Either.Left -> return result
                is Either.Right -> matches += result.value
            }
            if (result.value.size < config.pageSize || page >= MAX_PAGES) break
            page++
        }
        return Either.Right(matches)
    }

    private fun fetchPage(videogame: String, page: Int): SynciEither<List<PandaScoreMatch>> {
        val query = mapOf(
            "filter[videogame]" to videogame,
            "sort" to "scheduled_at",
            "per_page" to config.pageSize.toString(),
            "page" to page.toString(),
        ).entries.joinToString("&") { (k, v) -> "${encode(k)}=${encode(v)}" }
        val uri = URI.create("${config.url.trimEnd('/')}/matches/upcoming?$query")
        println("Fetching from $uri")
        return try {
            val response = webClient.get()
                .uri(uri)
                .header(HttpHeaders.AUTHORIZATION, "Bearer ${config.token}")
                .retrieve()
                .toEntity(String::class.java)
                .block() ?: return Either.Left(ExternalSourceError("PandaScore: empty response for $videogame"))
            response.headers.getFirst("X-Rate-Limit-Remaining")?.let { println("PandaScore: $it requests left this hour") }
            Either.Right(json.decodeFromString<List<PandaScoreMatch>>(response.body ?: "[]"))
        } catch (e: WebClientResponseException) {
            Either.Left(ExternalSourceError("PandaScore ${e.statusCode.value()} for $videogame: ${e.responseBodyAsString.take(200)}"))
        } catch (e: Exception) {
            Either.Left(ExternalSourceError("PandaScore request for $videogame failed: ${e.message}"))
        }
    }

    private fun encode(value: String) = URLEncoder.encode(value, StandardCharsets.UTF_8)

    private companion object {
        /** safety net against endless paging; 10 × 100 upcoming matches per game is far above reality */
        const val MAX_PAGES = 10
    }
}
