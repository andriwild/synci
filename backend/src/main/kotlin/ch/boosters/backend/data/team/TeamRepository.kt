package ch.boosters.backend.data.team

import ch.boosters.backend.data.syncConfig.SyncConfig
import ch.boosters.data.Tables.SYNC_CONFIGS_TABLE
import ch.boosters.data.Tables.TEAMS_TABLE
import org.jooq.DSLContext
import org.springframework.stereotype.Repository


@Repository
class TeamRepository (private val dslContext: DSLContext) {

    fun getAllTeams(): List<Team> {
        return dslContext.select().from(TEAMS_TABLE).fetch().map {
            Team(it.getValue(TEAMS_TABLE.ID), it.getValue(TEAMS_TABLE.SOURCE_ID), it.getValue(TEAMS_TABLE.NAME))
        }
    }
}