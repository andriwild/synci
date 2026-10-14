package ch.boosters.backend.auth

import arrow.core.Either
import arrow.core.raise.either
import arrow.core.raise.ensure
import ch.boosters.backend.errorhandling.ExternalServiceError
import ch.boosters.backend.errorhandling.SynciEither
import com.fasterxml.jackson.annotation.JsonProperty
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.http.client.SimpleClientHttpRequestFactory
import org.springframework.stereotype.Component
import org.springframework.web.client.HttpClientErrorException
import org.springframework.web.client.RestClient
import java.time.Duration
import java.time.Instant

@Component
class Auth0ManagementClient(private val properties: Auth0ManagementProperties) {

    private val restClient = RestClient.builder()
        .requestFactory(SimpleClientHttpRequestFactory().apply {
            setConnectTimeout(Duration.ofSeconds(5))
            setReadTimeout(Duration.ofSeconds(10))
        })
        .build()

    @Volatile
    private var cachedToken: CachedToken? = null

    fun deleteUser(auth0Id: String): SynciEither<Unit> = either {
        ensure(properties.domain.isNotBlank() && properties.clientId.isNotBlank() && properties.clientSecret.isNotBlank()) {
            ExternalServiceError("Auth0 Management API ist nicht konfiguriert (auth0.management.*)")
        }
        Either.catch {
            try {
                restClient.delete()
                    // Spring encodes the "|" in the ID
                    .uri("https://{domain}/api/v2/users/{id}", properties.domain, auth0Id)
                    .header(HttpHeaders.AUTHORIZATION, "Bearer ${accessToken()}")
                    .retrieve()
                    .toBodilessEntity()
            } catch (e: HttpClientErrorException.NotFound) {
                // Already deleted, e.g. on a retry
            }
            Unit
        }.mapLeft { ExternalServiceError("Auth0-Benutzer $auth0Id konnte nicht gelöscht werden: ${it.message}") }.bind()
    }

    private fun accessToken(): String {
        cachedToken?.takeIf { it.expiresAt.isAfter(Instant.now().plusSeconds(60)) }?.let { return it.value }

        val response = restClient.post()
            .uri("https://{domain}/oauth/token", properties.domain)
            .contentType(MediaType.APPLICATION_JSON)
            .body(
                mapOf(
                    "grant_type" to "client_credentials",
                    "client_id" to properties.clientId,
                    "client_secret" to properties.clientSecret,
                    "audience" to "https://${properties.domain}/api/v2/",
                )
            )
            .retrieve()
            .body(TokenResponse::class.java)
            ?: error("Leere Token-Antwort von Auth0")

        return CachedToken(response.accessToken, Instant.now().plusSeconds(response.expiresIn))
            .also { cachedToken = it }
            .value
    }

    private data class CachedToken(val value: String, val expiresAt: Instant)

    private data class TokenResponse(
        @JsonProperty("access_token") val accessToken: String,
        @JsonProperty("expires_in") val expiresIn: Long,
    )
}
