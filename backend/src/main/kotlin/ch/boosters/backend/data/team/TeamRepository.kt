package ch.boosters.backend.data.team

import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.data.syncConfig.model.TeamDto
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.Tables.TEAMS_TABLE
import ch.boosters.data.tables.pojos.TeamsTable
import org.springframework.stereotype.Repository


@Repository
class TeamRepository(private val dsl: JooqEitherDsl) {
    fun getAllTeams(): SynciEither<List<Team>> =
        dsl {
            it.select().from(TEAMS_TABLE).fetch().map {
                Team(
                    it.getValue(TEAMS_TABLE.ID),
                    it.getValue(TEAMS_TABLE.SOURCE_ID),
                    it.getValue(TEAMS_TABLE.NAME)
                )
            }
        }

    fun getTeamsByIds(ids: List<TeamDto>): SynciEither<List<TeamsTable>> =
        dsl {
            it.selectFrom(TEAMS_TABLE)
                .where(TEAMS_TABLE.ID.`in`(ids.map { it.id }).and(TEAMS_TABLE.SOURCE_ID.`in`(ids.map { it.sourceId })))
                .fetchInto(TeamsTable::class.java)
        }
}
