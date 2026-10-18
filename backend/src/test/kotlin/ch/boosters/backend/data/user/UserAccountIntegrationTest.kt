package ch.boosters.backend.data.user

import arrow.core.left
import arrow.core.right
import ch.boosters.backend.auth.Auth0ManagementClient
import ch.boosters.backend.errorhandling.ExternalSourceError
import ch.boosters.data.tables.references.SYNC_CONFIGS_TABLE
import ch.boosters.data.tables.references.SYNC_CONFIGS_USERS_TABLE
import ch.boosters.data.tables.references.USERS_TABLE
import com.nimbusds.jose.JWSAlgorithm
import com.nimbusds.jose.JWSHeader
import com.nimbusds.jose.crypto.RSASSASigner
import com.nimbusds.jwt.JWTClaimsSet
import com.nimbusds.jwt.SignedJWT
import org.jooq.DSLContext
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNotNull
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.mockito.BDDMockito.given
import org.mockito.Mockito.verify
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.mock.mockito.MockBean
import org.springframework.boot.test.web.client.TestRestTemplate
import org.springframework.http.HttpEntity
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpMethod
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.test.context.DynamicPropertyRegistry
import org.springframework.test.context.DynamicPropertySource
import org.testcontainers.containers.PostgreSQLContainer
import org.testcontainers.junit.jupiter.Container
import org.testcontainers.junit.jupiter.Testcontainers
import java.nio.file.Files
import java.security.KeyPairGenerator
import java.time.Instant
import java.util.Base64
import java.util.Date
import java.util.UUID
import java.util.concurrent.CountDownLatch
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
class UserAccountIntegrationTest {

    @Autowired
    lateinit var rest: TestRestTemplate

    @Autowired
    lateinit var dsl: DSLContext

    @MockBean
    lateinit var auth0ManagementClient: Auth0ManagementClient

    @Test
    fun `accepts tokens for the new and the old audience`() {
        listOf(NEW_AUDIENCE, OLD_AUDIENCE).forEach { audience ->
            assertEquals(HttpStatus.OK, get("/syncconfigs", token(newSubject(), audience)).statusCode, audience)
        }
    }

    @Test
    fun `rejects missing, foreign and expired tokens`() {
        assertEquals(HttpStatus.UNAUTHORIZED, get("/syncconfigs", null).statusCode)
        assertEquals(HttpStatus.UNAUTHORIZED, get("/syncconfigs", token(newSubject(), "https://example.com/api")).statusCode)
        assertEquals(
            HttpStatus.UNAUTHORIZED,
            get("/syncconfigs", token(newSubject(), expiresAt = Instant.now().minusSeconds(300))).statusCode
        )
        assertEquals(HttpStatus.OK, get("/sports", null).statusCode)
    }

    @Test
    fun `creates one user with one default sync config for parallel first requests`() {
        val subject = newSubject()
        val token = token(subject)
        val pool = Executors.newFixedThreadPool(8)
        val start = CountDownLatch(1)

        val responses = (1..8).map { pool.submit<HttpStatus> { start.await(); HttpStatus.valueOf(get("/syncconfigs", token).statusCode.value()) } }
        start.countDown()
        val statuses = responses.map { it.get(30, TimeUnit.SECONDS) }
        pool.shutdown()

        assertTrue(statuses.all { it == HttpStatus.OK }, statuses.toString())
        assertEquals(1, dsl.fetchCount(USERS_TABLE, USERS_TABLE.AUTH0_ID.eq(subject)))
        assertEquals(1, syncConfigIds(userId(subject)!!).size)
    }

    @Test
    fun `deletes the user with all sync configs in Auth0 and the database`() {
        val subject = newSubject()
        val token = token(subject)
        get("/syncconfigs", token)
        val userId = userId(subject)!!
        val syncConfigId = syncConfigIds(userId).single()
        assertEquals(HttpStatus.OK, calendarStatus(syncConfigId))
        given(auth0ManagementClient.deleteUser(subject)).willReturn(Unit.right())

        val response = exchange(HttpMethod.DELETE, "/users/me", token)

        assertEquals("OK", response.body?.get("statusCode"))
        assertEquals(1, response.body?.get("body"))
        verify(auth0ManagementClient).deleteUser(subject)
        assertNull(userId(subject))
        assertEquals(0, syncConfigIds(userId).size)
        assertEquals(0, dsl.fetchCount(SYNC_CONFIGS_TABLE, SYNC_CONFIGS_TABLE.ID.eq(syncConfigId)))
        assertEquals(HttpStatus.NOT_FOUND, calendarStatus(syncConfigId))
    }

    @Test
    fun `keeps the data when Auth0 fails`() {
        val subject = newSubject()
        val token = token(subject)
        get("/syncconfigs", token)
        given(auth0ManagementClient.deleteUser(subject)).willReturn(ExternalSourceError("Auth0 is down").left())

        val response = exchange(HttpMethod.DELETE, "/users/me", token)

        assertEquals("BAD_GATEWAY", response.body?.get("statusCode"))
        val userId = userId(subject)
        assertNotNull(userId)
        assertEquals(1, syncConfigIds(userId!!).size)
    }

    private fun get(path: String, token: String?) = exchange(HttpMethod.GET, path, token)

    private fun exchange(method: HttpMethod, path: String, token: String?): ResponseEntity<Map<*, *>> {
        val headers = HttpHeaders().apply { token?.let { setBearerAuth(it) } }
        return rest.exchange(path, method, HttpEntity<Void>(headers), Map::class.java)
    }

    private fun calendarStatus(syncConfigId: UUID?) =
        rest.getForEntity("/calendars/$syncConfigId/subscribe", String::class.java).statusCode

    private fun userId(subject: String): UUID? =
        dsl.select(USERS_TABLE.ID).from(USERS_TABLE).where(USERS_TABLE.AUTH0_ID.eq(subject)).fetchOne(USERS_TABLE.ID)

    private fun syncConfigIds(userId: UUID): List<UUID?> =
        dsl.select(SYNC_CONFIGS_USERS_TABLE.SYNC_CONFIG_ID)
            .from(SYNC_CONFIGS_USERS_TABLE)
            .where(SYNC_CONFIGS_USERS_TABLE.USER_ID.eq(userId))
            .fetch(SYNC_CONFIGS_USERS_TABLE.SYNC_CONFIG_ID)

    companion object {
        private const val NEW_AUDIENCE = "https://synci.ch/api"
        private const val OLD_AUDIENCE = "https://synci.awild.ch"

        @Container
        @JvmStatic
        val postgres = PostgreSQLContainer<Nothing>("postgres:15.2-alpine")

        private val keyPair = KeyPairGenerator.getInstance("RSA").apply { initialize(2048) }.generateKeyPair()

        @DynamicPropertySource
        @JvmStatic
        fun properties(registry: DynamicPropertyRegistry) {
            registry.add("ch.boosters.db.jdbcUrl", postgres::getJdbcUrl)
            registry.add("ch.boosters.db.username", postgres::getUsername)
            registry.add("ch.boosters.db.password", postgres::getPassword)
            // Local key instead of Auth0; the audience is still validated
            registry.add("spring.security.oauth2.resourceserver.jwt.issuer-uri") { "" }
            registry.add("spring.security.oauth2.resourceserver.jwt.public-key-location") { publicKeyLocation() }
            registry.add("spring.quartz.auto-startup") { false }
        }

        private fun publicKeyLocation(): String {
            val pem = Base64.getMimeEncoder(64, "\n".toByteArray()).encodeToString(keyPair.public.encoded)
            val file = Files.createTempFile("jwt", ".pem")
            Files.writeString(file, "-----BEGIN PUBLIC KEY-----\n$pem\n-----END PUBLIC KEY-----\n")
            file.toFile().deleteOnExit()
            return file.toUri().toString()
        }

        private fun newSubject() = "auth0|test-${UUID.randomUUID()}"

        private fun token(
            subject: String,
            audience: String = NEW_AUDIENCE,
            expiresAt: Instant = Instant.now().plusSeconds(300),
        ): String {
            val claims = JWTClaimsSet.Builder()
                .subject(subject)
                .audience(audience)
                .issueTime(Date.from(expiresAt.minusSeconds(600)))
                .expirationTime(Date.from(expiresAt))
                .claim("email", "test@synci.ch")
                .build()
            return SignedJWT(JWSHeader(JWSAlgorithm.RS256), claims)
                .apply { sign(RSASSASigner(keyPair.private)) }
                .serialize()
        }
    }
}
