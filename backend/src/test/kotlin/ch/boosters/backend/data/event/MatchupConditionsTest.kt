package ch.boosters.backend.data.event

import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.data.enums.GenderType
import ch.boosters.data.tables.records.EventsTableRecord
import ch.boosters.data.tables.records.EventsTeamsTableRecord
import ch.boosters.data.tables.references.EVENTS_TABLE
import ch.boosters.data.tables.references.EVENTS_TEAMS_TABLE
import ch.boosters.data.tables.references.SOURCES_TABLE
import ch.boosters.data.tables.references.SPORTS_TABLE
import ch.boosters.data.tables.references.SYNC_CONFIGS_MATCHUPS_TABLE
import ch.boosters.data.tables.references.SYNC_CONFIGS_TABLE
import ch.boosters.data.tables.references.TEAMS_TABLE
import org.flywaydb.core.Flyway
import org.jooq.DSLContext
import org.jooq.SQLDialect
import org.jooq.impl.DSL
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.BeforeAll
import org.junit.jupiter.api.Test
import org.postgresql.ds.PGSimpleDataSource
import org.testcontainers.containers.PostgreSQLContainer
import org.testcontainers.junit.jupiter.Container
import org.testcontainers.junit.jupiter.Testcontainers
import java.time.LocalDateTime
import java.util.UUID

@Testcontainers
class MatchupConditionsTest {

    private val eventRepository = EventRepository(JooqEitherDsl(dsl))

    @Test
    fun `finds the games of a Top Event in every competition and with either team at home`() {
        val configId = UUID.randomUUID()
        dsl.insertInto(SYNC_CONFIGS_TABLE).set(SYNC_CONFIGS_TABLE.ID, configId).set(SYNC_CONFIGS_TABLE.NAME, "Test").execute()
        dsl.insertInto(SYNC_CONFIGS_MATCHUPS_TABLE)
            .set(SYNC_CONFIGS_MATCHUPS_TABLE.SYNC_CONFIG_ID, configId)
            .set(SYNC_CONFIGS_MATCHUPS_TABLE.SOURCE_ID, swissTxt)
            .set(SYNC_CONFIGS_MATCHUPS_TABLE.TEAM_A_ID, barca)
            .set(SYNC_CONFIGS_MATCHUPS_TABLE.TEAM_B_ID, real)
            .set(SYNC_CONFIGS_MATCHUPS_TABLE.POSITION, 0)
            .execute()

        val events = eventRepository.eventsOfMatchups(configId).getOrNull()!!.sortedBy { it.startsOn }.map { it.id }

        assertEquals(listOf(pastClasico, leagueClasico, cupClasico), events)
    }

    @Test
    fun `previews the upcoming games of two teams in either order`() {
        val now = LocalDateTime.now()

        listOf(real to barca, barca to real).forEach { (teamA, teamB) ->
            val page = eventRepository.upcomingEventsOfMatchup(swissTxt, teamA, teamB, 10, 0, now).getOrNull()!!.map { it.id }
            assertEquals(listOf(leagueClasico, cupClasico), page)
            assertEquals(2, eventRepository.upcomingEventsOfMatchupCount(swissTxt, teamA, teamB, now).getOrNull())
        }
    }

    @Test
    fun `adds the teams of each event in the order of its name`() {
        val events = listOf(leagueClasico, cupClasico, derby).map { eventRepository.findEvent(it, swissTxt).getOrNull()!! }

        val teams = eventRepository.withTeams(events).getOrNull()!!.map { response -> response.teams.map { it.id } }

        assertEquals(listOf(listOf(real, barca), listOf(barca, real), listOf(real, atletico)), teams)
    }

    companion object {
        @Container
        @JvmStatic
        val postgres = PostgreSQLContainer<Nothing>("postgres:15.2-alpine")

        private lateinit var dsl: DSLContext
        private var swissTxt = 0

        private lateinit var real: String
        private lateinit var barca: String
        private lateinit var atletico: String
        private lateinit var pastClasico: String
        private lateinit var derby: String
        private lateinit var leagueClasico: String
        private lateinit var cupClasico: String

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

            real = newTeam()
            barca = newTeam()
            atletico = newTeam()
            val league = newSport()
            val cup = newSport()

            pastClasico = newGame(league, real, barca, -30)
            derby = newGame(league, real, atletico, 5)
            leagueClasico = newGame(league, real, barca, 10)
            cupClasico = newGame(cup, barca, real, 20)
        }

        private fun newSport(): UUID {
            val id = UUID.randomUUID()
            dsl.insertInto(SPORTS_TABLE).set(SPORTS_TABLE.ID, id).set(SPORTS_TABLE.NAME, "TEST_$id").execute()
            return id
        }

        private fun newTeam(): String {
            val id = UUID.randomUUID().toString()
            dsl.insertInto(TEAMS_TABLE)
                .set(TEAMS_TABLE.ID, id)
                .set(TEAMS_TABLE.SOURCE_ID, swissTxt)
                .set(TEAMS_TABLE.NAME, "Team $id")
                .set(TEAMS_TABLE.GENDER, GenderType.MAN)
                .execute()
            return id
        }

        private fun newGame(sportId: UUID, homeId: String, awayId: String, inDays: Long): String {
            val id = UUID.randomUUID().toString()
            val startsOn = LocalDateTime.now().plusDays(inDays)
            dsl.insertInto(EVENTS_TABLE)
                .set(EventsTableRecord(id = id, sourceId = swissTxt, name = "Team $homeId - Team $awayId", startsOn = startsOn, endsOn = startsOn.plusHours(2), sportId = sportId))
                .execute()
            listOf(homeId, awayId).forEach { teamId ->
                dsl.insertInto(EVENTS_TEAMS_TABLE)
                    .set(EventsTeamsTableRecord(id = UUID.randomUUID(), eventId = id, sourceEventId = swissTxt, teamId = teamId, sourceTeamId = swissTxt))
                    .execute()
            }
            return id
        }
    }
}
