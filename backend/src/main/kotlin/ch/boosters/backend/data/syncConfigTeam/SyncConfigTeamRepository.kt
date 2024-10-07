package ch.boosters.backend.data.syncConfigTeam

import ch.boosters.backend.data.team.Team
import ch.boosters.data.Tables.SYNC_CONFIGS_TEAMS_TABLE
import org.jooq.DSLContext
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class SyncConfigTeamRepository (private val dsl: DSLContext) {

    fun updateTeams(configId: UUID, teams: List<Team>) {
        dsl.deleteFrom(SYNC_CONFIGS_TEAMS_TABLE)
            .where(SYNC_CONFIGS_TEAMS_TABLE.SYNC_CONFIG_ID.eq(configId))
            .execute()
        addTeams(configId, teams)
    }

    fun addTeams(configId: UUID, teams: List<Team>) {

        val queries = teams.map {
            val teamUuid = UUID.randomUUID()
            dsl.insertInto(SYNC_CONFIGS_TEAMS_TABLE)
                .columns(
                    SYNC_CONFIGS_TEAMS_TABLE.ID,
                    SYNC_CONFIGS_TEAMS_TABLE.SYNC_CONFIG_ID,
                    SYNC_CONFIGS_TEAMS_TABLE.TEAM_ID,
                    SYNC_CONFIGS_TEAMS_TABLE.SOURCE_ID
                )
                .values(teamUuid, configId, it.id, it.source)
        }
        dsl.batch(queries).execute()
    }
}
