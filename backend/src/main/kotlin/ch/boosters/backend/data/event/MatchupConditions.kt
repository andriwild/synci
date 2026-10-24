package ch.boosters.backend.data.event

import ch.boosters.data.tables.EventsTable.Companion.EVENTS_TABLE
import ch.boosters.data.tables.EventsTeamsTable
import ch.boosters.data.tables.EventsTeamsTable.Companion.EVENTS_TEAMS_TABLE
import ch.boosters.data.tables.SyncConfigsMatchupsTable.Companion.SYNC_CONFIGS_MATCHUPS_TABLE
import org.jooq.Condition
import org.jooq.Field
import org.jooq.impl.DSL
import java.util.UUID

/** The event is a game between [teamA] and [teamB] of [sourceId], with either team at home. */
private fun playsBoth(teamA: Field<String?>, teamB: Field<String?>, sourceId: Field<Int?>): Condition {
    fun plays(link: EventsTeamsTable, teamId: Field<String?>) = DSL.exists(
        DSL.selectOne().from(link)
            .where(link.EVENT_ID.eq(EVENTS_TABLE.ID))
            .and(link.SOURCE_EVENT_ID.eq(EVENTS_TABLE.SOURCE_ID))
            .and(link.TEAM_ID.eq(teamId))
            .and(link.SOURCE_TEAM_ID.eq(sourceId))
    )
    return EVENTS_TABLE.SOURCE_ID.eq(sourceId)
        .and(plays(EVENTS_TEAMS_TABLE.`as`("team_a"), teamA))
        .and(plays(EVENTS_TEAMS_TABLE.`as`("team_b"), teamB))
}

/** Games of the Top Events of the Abo [syncConfigId]. */
fun eventsOfConfigMatchups(syncConfigId: UUID): Condition =
    DSL.exists(
        DSL.selectOne().from(SYNC_CONFIGS_MATCHUPS_TABLE)
            .where(SYNC_CONFIGS_MATCHUPS_TABLE.SYNC_CONFIG_ID.eq(syncConfigId))
            .and(
                playsBoth(
                    SYNC_CONFIGS_MATCHUPS_TABLE.TEAM_A_ID,
                    SYNC_CONFIGS_MATCHUPS_TABLE.TEAM_B_ID,
                    SYNC_CONFIGS_MATCHUPS_TABLE.SOURCE_ID
                )
            )
    )

/** Games between [teamA] and [teamB], e.g. to preview a Top Event before it is added. */
fun eventsOfMatchup(sourceId: Int, teamA: String, teamB: String): Condition =
    playsBoth(DSL.value<String?>(teamA), DSL.value<String?>(teamB), DSL.value<Int?>(sourceId))
