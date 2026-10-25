package ch.boosters.backend.data.organisation

import ch.boosters.backend.auth.Auth0ManagementClient
import ch.boosters.data.tables.references.SYNC_CONFIGS_EVENTS_TABLE
import ch.boosters.data.tables.references.SYNC_CONFIGS_USERS_TABLE
import ch.boosters.data.tables.references.USERS_TABLE
import com.nimbusds.jose.JWSAlgorithm
import com.nimbusds.jose.JWSHeader
import com.nimbusds.jose.crypto.RSASSASigner
import com.nimbusds.jwt.JWTClaimsSet
import com.nimbusds.jwt.SignedJWT
import org.jooq.DSLContext
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.mock.mockito.MockBean
import org.springframework.boot.test.web.client.TestRestTemplate
import org.springframework.http.HttpEntity
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpMethod
import org.springframework.test.context.DynamicPropertyRegistry
import org.springframework.test.context.DynamicPropertySource
import org.testcontainers.containers.PostgreSQLContainer
import org.testcontainers.junit.jupiter.Container
import org.testcontainers.junit.jupiter.Testcontainers
import java.nio.file.Files
import java.security.KeyPairGenerator
import java.time.Instant
import java.time.LocalDate
import java.util.Base64
import java.util.Date
import java.util.UUID

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
class OrganisationEventResponseIntegrationTest {

    @Autowired
    lateinit var rest: TestRestTemplate

    @Autowired
    lateinit var dsl: DSLContext

    @MockBean
    lateinit var auth0ManagementClient: Auth0ManagementClient

    /** An organisation with an admin, an approved member and an event that asks for answers. */
    private inner class Club {
        val admin = token(newSubject(), "Admin")
        val member = token(newSubject(), "Mia")
        val organisationId: String
        val eventId: String

        init {
            val organisation = body(exchange(HttpMethod.POST, "/organisations", admin, mapOf("name" to "FC ${UUID.randomUUID()}")))
            organisationId = organisation["id"] as String
            val rootSportId = (organisation["sport"] as Map<*, *>)["id"] as String
            val request = body(exchange(HttpMethod.POST, "/organisations/$organisationId/join-requests", member))
            exchange(HttpMethod.PUT, "/organisations/$organisationId/members/${request["id"]}/approve", admin)
            eventId = createEvent(rootSportId, responseRequested = true)
        }

        fun createEvent(sportId: String, responseRequested: Boolean): String {
            val event = mapOf(
                "name" to "Training",
                "startsOn" to LocalDate.now().plusDays(3).atTime(19, 0).toString(),
                "endsOn" to LocalDate.now().plusDays(3).atTime(21, 0).toString(),
                "sportId" to sportId,
                "responseRequested" to responseRequested
            )
            return body(exchange(HttpMethod.POST, "/organisations/$organisationId/events", admin, event))["id"] as String
        }

        fun answer(token: String, answer: String, eventId: String = this.eventId) =
            exchange(HttpMethod.PUT, "/organisations/$organisationId/events/$eventId/response", token, mapOf("answer" to answer))

        fun summaries(token: String) = exchange(HttpMethod.GET, "/organisations/$organisationId/responses", token)
            .let { (it["body"] as List<*>).map { summary -> summary as Map<*, *> } }

        fun memberConfigId(): UUID = syncConfigOf(member)
    }

    @Test
    fun `members answer and change their answer, admins see who answered`() {
        val club = Club()

        val first = body(club.answer(club.member, "YES"))
        assertEquals(listOf(1, 0, 1, "YES"), listOf(first["yes"], first["no"], first["open"], first["myAnswer"]))
        assertNull(first["members"])

        val changed = body(club.answer(club.member, "NO"))
        assertEquals(listOf(0, 1, 1, "NO"), listOf(changed["yes"], changed["no"], changed["open"], changed["myAnswer"]))

        val forAdmin = club.summaries(club.admin).single()
        assertEquals(club.eventId, forAdmin["eventId"])
        assertNull(forAdmin["myAnswer"])
        assertEquals(
            listOf(mapOf("name" to "Mia", "answer" to "NO"), mapOf("name" to "Admin", "answer" to null)),
            forAdmin["members"]
        )
        assertNull(club.summaries(club.member).single()["members"])
    }

    @Test
    fun `the calendar links to the answer page, which answers without login`() {
        val club = Club()
        val configId = club.memberConfigId()
        dsl.insertInto(SYNC_CONFIGS_EVENTS_TABLE)
            .set(SYNC_CONFIGS_EVENTS_TABLE.ID, UUID.randomUUID())
            .set(SYNC_CONFIGS_EVENTS_TABLE.SYNC_CONFIG_ID, configId)
            .set(SYNC_CONFIGS_EVENTS_TABLE.EVENT_ID, club.eventId)
            .set(SYNC_CONFIGS_EVENTS_TABLE.SOURCE_EVENT_ID, organisationSourceId())
            .execute()

        val ics = rest.getForObject("/calendars/$configId/subscribe", String::class.java).replace("\r\n ", "")
        assertTrue(ics.contains("Zu- oder absagen: https://synci.ch/antwort/$configId/${club.eventId}"), ics)

        val link = "/calendars/$configId/events/${club.eventId}/response"
        val invitation = body(exchange(HttpMethod.GET, link, null))
        assertEquals(listOf("Training", null), listOf(invitation["name"], invitation["answer"]))
        assertTrue((invitation["organisation"] as String).startsWith("FC "))

        assertEquals("YES", body(exchange(HttpMethod.PUT, link, null, mapOf("answer" to "YES")))["answer"])
        assertEquals("NO", body(exchange(HttpMethod.PUT, link, null, mapOf("answer" to "NO")))["answer"])
        assertEquals(1, club.summaries(club.admin).single()["no"])
    }

    @Test
    fun `only members answer, and only events that ask for it`() {
        val club = Club()
        val outsider = token(newSubject(), "Olaf")
        exchange(HttpMethod.GET, "/syncconfigs", outsider)

        assertEquals("FORBIDDEN", club.answer(outsider, "YES")["statusCode"])
        val rootSportId = body(exchange(HttpMethod.GET, "/organisations/${club.organisationId}", club.admin))
            .let { (it["sport"] as Map<*, *>)["id"] as String }
        val withoutAnswers = club.createEvent(rootSportId, responseRequested = false)
        assertEquals("BAD_REQUEST", club.answer(club.member, "YES", withoutAnswers)["statusCode"])
        assertEquals(
            "NOT_FOUND",
            exchange(HttpMethod.GET, "/calendars/${UUID.randomUUID()}/events/${club.eventId}/response", null)["statusCode"]
        )
        assertEquals(
            "FORBIDDEN",
            exchange(HttpMethod.GET, "/calendars/${syncConfigOf(outsider)}/events/${club.eventId}/response", null)["statusCode"]
        )
    }

    @Test
    fun `answers of members who left no longer count and their link stops working`() {
        val club = Club()
        val configId = club.memberConfigId()
        club.answer(club.member, "YES")

        exchange(HttpMethod.DELETE, "/organisations/${club.organisationId}/members/me", club.member)

        val summary = club.summaries(club.admin).single()
        assertEquals(listOf(0, 1), listOf(summary["yes"], summary["open"]))
        assertEquals(
            "FORBIDDEN",
            exchange(HttpMethod.GET, "/calendars/$configId/events/${club.eventId}/response", null)["statusCode"]
        )
    }

    private fun body(response: Map<*, *>): Map<*, *> {
        assertEquals("OK", response["statusCode"], response.toString())
        return response["body"] as Map<*, *>
    }

    private fun exchange(method: HttpMethod, path: String, token: String?, body: Any? = null): Map<*, *> {
        val headers = HttpHeaders().apply { token?.let { setBearerAuth(it) } }
        return rest.exchange(path, method, HttpEntity(body, headers), Map::class.java).body!!
    }

    private fun syncConfigOf(token: String): UUID {
        exchange(HttpMethod.GET, "/syncconfigs", token)
        val subject = SignedJWT.parse(token).jwtClaimsSet.subject
        return dsl.select(SYNC_CONFIGS_USERS_TABLE.SYNC_CONFIG_ID)
            .from(SYNC_CONFIGS_USERS_TABLE)
            .join(USERS_TABLE).on(USERS_TABLE.ID.eq(SYNC_CONFIGS_USERS_TABLE.USER_ID))
            .where(USERS_TABLE.AUTH0_ID.eq(subject))
            .fetch(SYNC_CONFIGS_USERS_TABLE.SYNC_CONFIG_ID)
            .first()!!
    }

    private fun organisationSourceId(): Int =
        dsl.fetchValue("select id from sources_table where name = ?", ORGANISATION_SOURCE_NAME) as Int

    companion object {
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

        private fun token(subject: String, name: String): String {
            val now = Instant.now()
            val claims = JWTClaimsSet.Builder()
                .subject(subject)
                .audience("https://synci.ch/api")
                .issueTime(Date.from(now))
                .expirationTime(Date.from(now.plusSeconds(300)))
                .claim("email", "${name.lowercase()}@synci.ch")
                .claim("name", name)
                .build()
            return SignedJWT(JWSHeader(JWSAlgorithm.RS256), claims)
                .apply { sign(RSASSASigner(keyPair.private)) }
                .serialize()
        }
    }
}
