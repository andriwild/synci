package ch.boosters.backend.data.team.teamSports

import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.data.team.Gender
import ch.boosters.backend.data.team.Team
import ch.boosters.data.enums.GenderType
import ch.boosters.data.tables.references.SOURCES_TABLE
import ch.boosters.data.tables.references.SPORTS_TABLE
import ch.boosters.data.tables.references.TEAMS_SPORTS_TABLE
import ch.boosters.data.tables.references.TEAMS_TABLE
import org.flywaydb.core.Flyway
import org.jooq.DSLContext
import org.jooq.SQLDialect
import org.jooq.impl.DSL
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.fail
import org.junit.jupiter.api.BeforeAll
import org.junit.jupiter.api.Test
import org.postgresql.ds.PGSimpleDataSource
import org.testcontainers.containers.PostgreSQLContainer
import org.testcontainers.junit.jupiter.Container
import org.testcontainers.junit.jupiter.Testcontainers
import java.util.UUID

@Testcontainers
class TeamSportsRepositoryTest {

    private val repository = TeamSportsRepository(JooqEitherDsl(dsl))

    @Test
    fun `moves promoted and relegated teams to their new league`() {
        val (a, b, c, d, e) = newTeams(5, swissTxt)
        val superLeague = newLeague()
        val challengeLeague = newLeague()
        replace(listOf(a, b, c), superLeague)
        replace(listOf(d, e), challengeLeague)

        // c is relegated, d promoted
        replace(listOf(a, b, d), superLeague)
        replace(listOf(c, e), challengeLeague)

        assertEquals(ids(a, b, d), linkedTeams(superLeague))
        assertEquals(ids(c, e), linkedTeams(challengeLeague))
    }

    @Test
    fun `keeps the teams when the source delivers none`() {
        val (a, b) = newTeams(2, swissTxt)
        val league = newLeague()
        replace(listOf(a, b), league)

        replace(emptyList(), league)

        assertEquals(ids(a, b), linkedTeams(league))
    }

    @Test
    fun `leaves teams of other sources alone`() {
        val (old, new) = newTeams(2, swissTxt)
        val (foreign) = newTeams(1, nflverse)
        val league = newLeague()
        repository.upsertTeams(listOf(old, foreign), league).onLeft { fail(it.toString()) }

        replace(listOf(new), league)

        assertEquals(ids(new, foreign), linkedTeams(league))
    }

    @Test
    fun `links each team once over repeated syncs`() {
        val (a, b, c) = newTeams(3, swissTxt)
        val league = newLeague()

        repeat(3) { replace(listOf(a, b, c), league) }

        assertEquals(ids(a, b, c), linkedTeams(league))
    }

    @Test
    fun `migration keeps one link per team and league`() {
        assertEquals(listOf(duplicatedTeam), linkedTeams(duplicatedLeague))
        assertEquals(listOf(duplicatedTeam), linkedTeams(otherDuplicatedLeague))
    }

    private fun replace(teams: List<Team>, sportId: UUID) =
        repository.replaceTeams(teams, sportId, swissTxt).onLeft { fail(it.toString()) }

    private fun ids(vararg teams: Team) = teams.map { it.id }.sorted()

    private fun linkedTeams(sportId: UUID): List<String> =
        dsl.select(TEAMS_SPORTS_TABLE.TEAM_ID)
            .from(TEAMS_SPORTS_TABLE)
            .where(TEAMS_SPORTS_TABLE.SPORT_ID.eq(sportId))
            .fetch(TEAMS_SPORTS_TABLE.TEAM_ID)
            .filterNotNull()
            .sorted()

    companion object {
        @Container
        @JvmStatic
        val postgres = PostgreSQLContainer<Nothing>("postgres:15.2-alpine")

        private lateinit var dsl: DSLContext
        private var swissTxt = 0
        private var nflverse = 0

        private lateinit var duplicatedTeam: String
        private lateinit var duplicatedLeague: UUID
        private lateinit var otherDuplicatedLeague: UUID

        @BeforeAll
        @JvmStatic
        fun migrate() {
            val dataSource = PGSimpleDataSource().apply {
                setURL(postgres.jdbcUrl)
                user = postgres.username
                password = postgres.password
            }
            dsl = DSL.using(dataSource, SQLDialect.POSTGRES)

            // links duplicated by syncs before the unique constraint existed
            flyway(dataSource, "4.5").migrate()
            swissTxt = sourceId("SWISSTXT")
            nflverse = sourceId("NFLVERSE")
            duplicatedTeam = newTeams(1, swissTxt).single().id
            duplicatedLeague = newLeague()
            otherDuplicatedLeague = newLeague()
            repeat(3) { insertLink(duplicatedTeam, duplicatedLeague) }
            insertLink(duplicatedTeam, otherDuplicatedLeague)

            flyway(dataSource, "latest").migrate()
        }

        private fun flyway(dataSource: PGSimpleDataSource, target: String) =
            Flyway.configure().dataSource(dataSource).locations("classpath:db/migration").target(target).load()

        private fun sourceId(name: String): Int =
            dsl.select(SOURCES_TABLE.ID).from(SOURCES_TABLE).where(SOURCES_TABLE.NAME.eq(name)).fetchSingle(SOURCES_TABLE.ID)!!

        private fun newLeague(): UUID {
            val id = UUID.randomUUID()
            dsl.insertInto(SPORTS_TABLE).set(SPORTS_TABLE.ID, id).set(SPORTS_TABLE.NAME, "TEST_$id").execute()
            return id
        }

        private fun newTeams(count: Int, sourceId: Int): List<Team> =
            List(count) {
                val team = Team(UUID.randomUUID().toString(), sourceId, "Team $it", Gender.MAN)
                dsl.insertInto(TEAMS_TABLE)
                    .set(TEAMS_TABLE.ID, team.id)
                    .set(TEAMS_TABLE.SOURCE_ID, sourceId)
                    .set(TEAMS_TABLE.NAME, team.name)
                    .set(TEAMS_TABLE.GENDER, GenderType.MAN)
                    .execute()
                team
            }

        private fun insertLink(teamId: String, sportId: UUID) =
            dsl.insertInto(TEAMS_SPORTS_TABLE)
                .set(TEAMS_SPORTS_TABLE.ID, UUID.randomUUID())
                .set(TEAMS_SPORTS_TABLE.TEAM_ID, teamId)
                .set(TEAMS_SPORTS_TABLE.SOURCE_TEAM_ID, swissTxt)
                .set(TEAMS_SPORTS_TABLE.SPORT_ID, sportId)
                .execute()
    }
}
