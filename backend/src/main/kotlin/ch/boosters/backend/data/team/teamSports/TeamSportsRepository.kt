package ch.boosters.backend.data.team.teamSports

import arrow.core.Either
import arrow.core.raise.either
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.data.syncConfig.model.TeamDto
import ch.boosters.backend.data.team.Team
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.backend.errorhandling.SynciError
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

    fun getTeamsBySportId(sportId: UUID): Either<SynciError, List<TeamDto>> =
        dsl {
            it.selectFrom(TEAMS_SPORTS_TABLE)
                .where(TEAMS_SPORTS_TABLE.SPORT_ID.eq(sportId))
                .fetch { record ->
                    TeamDto(
                        id = record.get(TEAMS_SPORTS_TABLE.TEAM_ID),
                        sourceId = record.get(TEAMS_SPORTS_TABLE.SOURCE_TEAM_ID)
                    )
                }
        }
}