package ch.boosters.backend.data.syncConfig.syncConfigMatchups

import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.data.event.EventRepository
import ch.boosters.backend.data.organisation.OrganisationAccess
import ch.boosters.backend.data.organisation.OrganisationMemberRepository
import ch.boosters.backend.data.sport.SportsRepository
import ch.boosters.backend.data.syncConfig.SyncConfig
import ch.boosters.backend.data.syncConfig.SyncConfigRepository
import ch.boosters.backend.data.syncConfig.SyncConfigService
import ch.boosters.backend.data.syncConfig.model.MatchupDto
import ch.boosters.backend.data.syncConfig.model.SyncConfigDto
import ch.boosters.backend.data.syncConfig.syncConfigEvents.SyncConfigEventsRepository
import ch.boosters.backend.data.syncConfig.syncConfigSports.SyncConfigSportsRepository
import ch.boosters.backend.data.syncConfig.syncConfigTeam.SyncConfigTeamRepository
import ch.boosters.backend.errorhandling.InvalidRequest
import ch.boosters.data.enums.GenderType
import ch.boosters.data.tables.references.SOURCES_TABLE
import ch.boosters.data.tables.references.TEAMS_TABLE
import ch.boosters.data.tables.references.USERS_TABLE
import org.flywaydb.core.Flyway
import org.jooq.DSLContext
import org.jooq.SQLDialect
import org.jooq.impl.DSL
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertInstanceOf
import org.junit.jupiter.api.BeforeAll
import org.junit.jupiter.api.Test
import org.postgresql.ds.PGSimpleDataSource
import org.testcontainers.containers.PostgreSQLContainer
import org.testcontainers.junit.jupiter.Container
import org.testcontainers.junit.jupiter.Testcontainers
import java.util.UUID

@Testcontainers
class SyncConfigMatchupsTest {

    private val service = JooqEitherDsl(dsl).let {
        SyncConfigService(
            SyncConfigRepository(it),
            SyncConfigTeamRepository(it),
            SyncConfigSportsRepository(it),
            SyncConfigEventsRepository(it),
            SyncConfigMatchupRepository(it),
            SportsRepository(it),
            EventRepository(it),
            OrganisationAccess(OrganisationMemberRepository(it)),
        )
    }
    private val userId = newUser()
    private val configId = service.createSyncConfig(dto(), userId).getOrNull()!!.id!!

    @Test
    fun `starts a new Abo without Top Events`() {
        assertEquals(emptyList<String>(), names(service.createSyncConfig(dto(), userId).getOrNull()!!))
        assertEquals(emptyList<String>(), names(service.createSyncConfig(dto(emptyList()), userId).getOrNull()!!))
    }

    @Test
    fun `starts a new Abo with the Top Events the client sent`() {
        assertEquals(listOf("SC Bern – Fribourg-Gottéron"), names(service.createSyncConfig(dto(listOf(matchup(bern, gotteron))), userId).getOrNull()!!))
    }

    @Test
    fun `stores Top Events in the given order`() {
        val config = update(listOf(matchup(real, barca), matchup(bern, gotteron)))

        assertEquals(listOf("Real Madrid – FC Barcelona", "SC Bern – Fribourg-Gottéron"), names(config))
        assertEquals(MATCHUP_LIMIT, config.matchupLimit)
    }

    @Test
    fun `keeps the Top Events when a client sends none`() {
        update(listOf(matchup(real, barca)))

        val config = update(null)

        assertEquals(listOf("Real Madrid – FC Barcelona"), names(config))
    }

    @Test
    fun `removes the Top Events for an empty list`() {
        update(listOf(matchup(real, barca)))

        assertEquals(emptyList<String>(), names(update(emptyList())))
    }

    @Test
    fun `treats swapped teams as the same Top Event`() {
        val config = update(listOf(matchup(real, barca), matchup(barca, real)))

        assertEquals(listOf("Real Madrid – FC Barcelona"), names(config))
    }

    @Test
    fun `rejects unknown teams and more Top Events than allowed without changing the Abo`() {
        update(listOf(matchup(real, barca)))
        val tooMany = List(MATCHUP_LIMIT + 1) { matchup(real, "unknown-$it") }

        val unknown = service.updateSyncConfig(configId, dto(listOf(matchup(real, "unknown"))), userId)
        val overLimit = service.updateSyncConfig(configId, dto(tooMany), userId)

        assertInstanceOf(InvalidRequest::class.java, unknown.leftOrNull())
        assertInstanceOf(InvalidRequest::class.java, overLimit.leftOrNull())
        assertEquals(listOf("Real Madrid – FC Barcelona"), names(service.syncConfigById(configId, userId).getOrNull()!!))
    }

    private fun dto(matchups: List<MatchupDto>? = null) = SyncConfigDto(null, "Test", emptyList(), emptyList(), emptyList(), matchups)

    private fun matchup(teamA: String, teamB: String) = MatchupDto(swissTxt, teamA, teamB)

    private fun update(matchups: List<MatchupDto>?): SyncConfig =
        service.updateSyncConfig(configId, dto(matchups), userId).fold({ throw AssertionError(it.message) }, { it })

    private fun names(config: SyncConfig) = config.matchups.map { "${it.item.teamA.name} – ${it.item.teamB.name}" }

    companion object {
        @Container
        @JvmStatic
        val postgres = PostgreSQLContainer<Nothing>("postgres:15.2-alpine")

        private lateinit var dsl: DSLContext
        private var swissTxt = 0
        private lateinit var real: String
        private lateinit var barca: String
        private lateinit var bern: String
        private lateinit var gotteron: String

        @BeforeAll
        @JvmStatic
        fun setUp() {
            val dataSource = PGSimpleDataSource().apply {
                setURL(postgres.jdbcUrl)
                user = postgres.username
                password = postgres.password
            }
            Flyway.configure().dataSource(dataSource).locations("classpath:db/migration").load().migrate()
            dsl = DSL.using(dataSource, SQLDialect.POSTGRES)
            swissTxt = dsl.select(SOURCES_TABLE.ID).from(SOURCES_TABLE).where(SOURCES_TABLE.NAME.eq("SWISSTXT")).fetchSingle(SOURCES_TABLE.ID)!!
            real = newTeam("Real Madrid")
            barca = newTeam("FC Barcelona")
            bern = newTeam("SC Bern")
            gotteron = newTeam("Fribourg-Gottéron")
        }

        private fun newTeam(name: String, id: String = UUID.randomUUID().toString()): String {
            dsl.insertInto(TEAMS_TABLE)
                .set(TEAMS_TABLE.ID, id)
                .set(TEAMS_TABLE.SOURCE_ID, swissTxt)
                .set(TEAMS_TABLE.NAME, name)
                .set(TEAMS_TABLE.GENDER, GenderType.MAN)
                .execute()
            return id
        }

        private fun newUser(): UUID {
            val id = UUID.randomUUID()
            dsl.insertInto(USERS_TABLE).set(USERS_TABLE.ID, id).set(USERS_TABLE.AUTH0_ID, "auth0|test-$id").execute()
            return id
        }
    }
}
