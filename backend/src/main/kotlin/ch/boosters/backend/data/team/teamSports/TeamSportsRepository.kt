package ch.boosters.backend.data.team.teamSports

import arrow.core.raise.either
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.data.team.Team
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.tables.TeamsSportsTable.Companion.TEAMS_SPORTS_TABLE
import org.jooq.impl.DSL
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class TeamSportsRepository(private val dsl: JooqEitherDsl) {

    fun upsertTeams(teams: List<Team>, sportID: UUID): SynciEither<IntArray> = either {
        val queries = teams.map {
            val id = UUID.randomUUID()
            DSL.insertInto(TEAMS_SPORTS_TABLE).columns(
                TEAMS_SPORTS_TABLE.ID,
                TEAMS_SPORTS_TABLE.TEAM_ID,
                TEAMS_SPORTS_TABLE.SOURCE_TEAM_ID,
                TEAMS_SPORTS_TABLE.SPORT_ID
            ).values(id, it.id, it.source, sportID)
                .onDuplicateKeyIgnore()
        }
        dsl { it.batch(queries).execute() }.bind()
    }

    /**
     * Makes [teams] the teams of the sport node: links new ones and unlinks teams of [sourceId] that no longer
     * play there (e.g. after promotion or relegation). Skipped for an empty list so an outage of the source or
     * the break between seasons does not empty the league.
     */
    fun replaceTeams(teams: List<Team>, sportID: UUID, sourceId: Int): SynciEither<Unit> = either {
        if (teams.isEmpty()) return@either
        upsertTeams(teams, sportID).bind()
        dsl {
            it.deleteFrom(TEAMS_SPORTS_TABLE)
                .where(TEAMS_SPORTS_TABLE.SPORT_ID.eq(sportID))
                .and(TEAMS_SPORTS_TABLE.SOURCE_TEAM_ID.eq(sourceId))
                .and(TEAMS_SPORTS_TABLE.TEAM_ID.notIn(teams.map(Team::id)))
                .execute()
        }.bind()
    }
}
