package ch.boosters.backend.data.team.teamSports

import arrow.core.raise.either
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.data.team.Team
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.Tables.TEAMS_SPORTS_TABLE
import org.jooq.impl.DSL
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class TeamSportsRepository(private val dsl: JooqEitherDsl) {

    fun storeTeams(teams: List<Team>, sportID: UUID): SynciEither<IntArray> = either {
        val queries = teams.map {
            val id = UUID.randomUUID()
            DSL.insertInto(TEAMS_SPORTS_TABLE).columns(
                TEAMS_SPORTS_TABLE.ID,
                TEAMS_SPORTS_TABLE.TEAM_ID,
                TEAMS_SPORTS_TABLE.SOURCE_TEAM_ID,
                TEAMS_SPORTS_TABLE.SPORT_ID
            ).values(id, it.id, it.source, sportID)
        }
        dsl { it.batch(queries).execute() }.bind()
    }
}