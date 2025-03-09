package ch.boosters.backend.data.syncConfigTeam

import arrow.core.Either
import arrow.core.raise.either
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.data.team.Team
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.Tables.SYNC_CONFIGS_TEAMS_TABLE
import org.jooq.impl.DSL
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class SyncConfigTeamRepository(private val dsl: JooqEitherDsl) {

    fun updateTeams(configId: UUID, teams: List<Team>) = either {
        dsl {
            it.deleteFrom(SYNC_CONFIGS_TEAMS_TABLE)
                .where(SYNC_CONFIGS_TEAMS_TABLE.SYNC_CONFIG_ID.eq(configId))
                .execute()
        }.bind()
        addTeams(configId, teams)
    }

    fun addTeams(configId: UUID, teams: List<Team>): SynciEither<List<Team>> = either {
        val queries = teams.map {
            val teamUuid = UUID.randomUUID()
            DSL.insertInto(SYNC_CONFIGS_TEAMS_TABLE)
                .columns(
                    SYNC_CONFIGS_TEAMS_TABLE.ID,
                    SYNC_CONFIGS_TEAMS_TABLE.SYNC_CONFIG_ID,
                    SYNC_CONFIGS_TEAMS_TABLE.TEAM_ID,
                    SYNC_CONFIGS_TEAMS_TABLE.SOURCE_ID
                )
                .values(teamUuid, configId, it.id, it.source)
        }
        dsl { it.batch(queries).execute() }.bind()
        teams
    }
}
