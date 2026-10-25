package ch.boosters.backend.data.syncConfig.syncConfigMatchups

import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.data.syncConfig.model.MatchupDto
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.tables.SyncConfigsMatchupsTable.Companion.SYNC_CONFIGS_MATCHUPS_TABLE
import ch.boosters.data.tables.TeamsSportsTable.Companion.TEAMS_SPORTS_TABLE
import ch.boosters.data.tables.TeamsTable.Companion.TEAMS_TABLE
import ch.boosters.data.tables.pojos.TeamsTable
import org.jooq.impl.DSL
import org.springframework.stereotype.Repository
import java.util.*

/** A Top Event as stored, with both teams and the sports team A plays in. */
data class StoredMatchup(val sourceId: Int, val teamA: TeamsTable, val teamB: TeamsTable, val sportIds: List<UUID>)

@Repository
class SyncConfigMatchupRepository(private val dsl: JooqEitherDsl) {

    fun getMatchups(configId: UUID): SynciEither<List<StoredMatchup>> = dsl {
        val m = SYNC_CONFIGS_MATCHUPS_TABLE
        val a = TEAMS_TABLE.`as`("team_a")
        val b = TEAMS_TABLE.`as`("team_b")
        val sportIds = DSL.array(
            DSL.select(TEAMS_SPORTS_TABLE.SPORT_ID).from(TEAMS_SPORTS_TABLE)
                .where(TEAMS_SPORTS_TABLE.TEAM_ID.eq(m.TEAM_A_ID))
                .and(TEAMS_SPORTS_TABLE.SOURCE_TEAM_ID.eq(m.SOURCE_ID))
        )
        it.select(m.SOURCE_ID, sportIds, *a.fields(), *b.fields())
            .from(m)
            .join(a).on(a.ID.eq(m.TEAM_A_ID).and(a.SOURCE_ID.eq(m.SOURCE_ID)))
            .join(b).on(b.ID.eq(m.TEAM_B_ID).and(b.SOURCE_ID.eq(m.SOURCE_ID)))
            .where(m.SYNC_CONFIG_ID.eq(configId))
            .orderBy(m.POSITION)
            .fetch { r ->
                StoredMatchup(
                    sourceId = r[m.SOURCE_ID]!!,
                    teamA = r.into(a).into(TeamsTable::class.java),
                    teamB = r.into(b).into(TeamsTable::class.java),
                    sportIds = r[sportIds]?.filterNotNull() ?: emptyList(),
                )
            }
    }

    /** Teams of [matchups] that do not exist, as "sourceId:teamId". */
    fun unknownTeams(matchups: List<MatchupDto>): SynciEither<List<String>> = dsl {
        val wanted = matchups.flatMap { listOf(it.sourceId to it.teamAId, it.sourceId to it.teamBId) }.toSet()
        val known = it.select(TEAMS_TABLE.SOURCE_ID, TEAMS_TABLE.ID).from(TEAMS_TABLE)
            .where(TEAMS_TABLE.ID.`in`(wanted.map { (_, id) -> id }))
            .fetch { r -> r[TEAMS_TABLE.SOURCE_ID] to r[TEAMS_TABLE.ID] }
            .toSet()
        (wanted - known).map { (source, id) -> "$source:$id" }
    }

    /** Replaces the Top Events of the Abo with [matchups], in this order. */
    fun replaceMatchups(configId: UUID, matchups: List<MatchupDto>): SynciEither<Unit> = dsl {
        it.transaction { config ->
            val tx = DSL.using(config)
            tx.deleteFrom(SYNC_CONFIGS_MATCHUPS_TABLE).where(SYNC_CONFIGS_MATCHUPS_TABLE.SYNC_CONFIG_ID.eq(configId)).execute()
            matchups.forEachIndexed { position, matchup ->
                tx.insertInto(SYNC_CONFIGS_MATCHUPS_TABLE)
                    .set(SYNC_CONFIGS_MATCHUPS_TABLE.SYNC_CONFIG_ID, configId)
                    .set(SYNC_CONFIGS_MATCHUPS_TABLE.SOURCE_ID, matchup.sourceId)
                    .set(SYNC_CONFIGS_MATCHUPS_TABLE.TEAM_A_ID, matchup.teamAId)
                    .set(SYNC_CONFIGS_MATCHUPS_TABLE.TEAM_B_ID, matchup.teamBId)
                    .set(SYNC_CONFIGS_MATCHUPS_TABLE.POSITION, position)
                    .execute()
            }
        }
    }
}
