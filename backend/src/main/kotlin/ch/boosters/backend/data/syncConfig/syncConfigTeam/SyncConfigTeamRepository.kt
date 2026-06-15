package ch.boosters.backend.data.syncConfig.syncConfigTeam

import arrow.core.raise.either
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.data.syncConfig.model.TeamDto
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.tables.SyncConfigsTeamsTable.Companion.SYNC_CONFIGS_TEAMS_TABLE
import ch.boosters.data.tables.TeamsSportsTable.Companion.TEAMS_SPORTS_TABLE
import ch.boosters.data.tables.TeamsTable.Companion.TEAMS_TABLE
import ch.boosters.data.tables.pojos.TeamsTable
import org.jooq.DSLContext
import org.jooq.impl.DSL
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class SyncConfigTeamRepository(private val dsl: JooqEitherDsl) {

    fun getTeamBySyncConfigId(id: UUID): SynciEither<List<TeamsTable>> =
        dsl { it: DSLContext ->
            it
                .select(TEAMS_TABLE.asterisk())
                .from(TEAMS_TABLE)
                .join(SYNC_CONFIGS_TEAMS_TABLE)
                .on(
                    SYNC_CONFIGS_TEAMS_TABLE.TEAM_ID.eq(TEAMS_TABLE.ID)
                        .and(
                            SYNC_CONFIGS_TEAMS_TABLE.SOURCE_ID.eq(TEAMS_TABLE.SOURCE_ID)
                        )
                )
                .where(SYNC_CONFIGS_TEAMS_TABLE.SYNC_CONFIG_ID.eq(id))
                .fetchInto(TeamsTable::class.java)
        }

    fun getTeamSportPairsBySyncConfigId(id: UUID): SynciEither<List<Pair<String, UUID>>> =
        dsl { it: DSLContext ->
            it
                .select(SYNC_CONFIGS_TEAMS_TABLE.TEAM_ID, TEAMS_SPORTS_TABLE.SPORT_ID)
                .from(SYNC_CONFIGS_TEAMS_TABLE)
                .join(TEAMS_SPORTS_TABLE)
                .on(
                    SYNC_CONFIGS_TEAMS_TABLE.TEAM_ID.eq(TEAMS_SPORTS_TABLE.TEAM_ID)
                        .and(SYNC_CONFIGS_TEAMS_TABLE.SOURCE_ID.eq(TEAMS_SPORTS_TABLE.SOURCE_TEAM_ID))
                )
                .where(SYNC_CONFIGS_TEAMS_TABLE.SYNC_CONFIG_ID.eq(id))
                .fetch()
                .mapNotNull { r ->
                    val teamId = r.get(SYNC_CONFIGS_TEAMS_TABLE.TEAM_ID) ?: return@mapNotNull null
                    val sportId = r.get(TEAMS_SPORTS_TABLE.SPORT_ID) ?: return@mapNotNull null
                    teamId to sportId
                }
        }

    fun updateTeams(configId: UUID, teams: List<TeamDto>): SynciEither<List<TeamDto>> = either {
        dsl {
            it.deleteFrom(SYNC_CONFIGS_TEAMS_TABLE)
                .where(SYNC_CONFIGS_TEAMS_TABLE.SYNC_CONFIG_ID.eq(configId))
                .execute()
        }.bind()
        addTeams(configId, teams).bind()
    }

    fun addTeams(configId: UUID, teams: List<TeamDto>): SynciEither<List<TeamDto>> = either {
        val queries = teams.map {
            val teamUuid = UUID.randomUUID()
            DSL.insertInto(SYNC_CONFIGS_TEAMS_TABLE)
                .columns(
                    SYNC_CONFIGS_TEAMS_TABLE.ID,
                    SYNC_CONFIGS_TEAMS_TABLE.SYNC_CONFIG_ID,
                    SYNC_CONFIGS_TEAMS_TABLE.TEAM_ID,
                    SYNC_CONFIGS_TEAMS_TABLE.SOURCE_ID
                )
                .values(teamUuid, configId, it.id, it.sourceId)
        }
        dsl { it.batch(queries).execute() }.bind()
        teams
    }
}
