package ch.boosters.backend.data.team

import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.tables.TeamsTable.Companion.TEAMS_TABLE
import ch.boosters.data.tables.pojos.TeamsTable
import org.springframework.stereotype.Repository


@Repository
class TeamRepository(private val dsl: JooqEitherDsl) {
    fun getAllTeams(): SynciEither<List<TeamsTable>> =
        dsl { it.select().from(TEAMS_TABLE).fetchInto(TeamsTable::class.java) }
}
