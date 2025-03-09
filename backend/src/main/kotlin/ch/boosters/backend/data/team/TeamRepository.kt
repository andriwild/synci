package ch.boosters.backend.data.team

import arrow.core.raise.either
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.Tables.TEAMS_TABLE
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
}
