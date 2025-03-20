package ch.boosters.backend.data.sport

import arrow.core.Either
import arrow.core.raise.either
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.backend.errorhandling.SynciError
import ch.boosters.data.Tables
import ch.boosters.data.tables.TeamsSportsTable.TEAMS_SPORTS_TABLE
import ch.boosters.data.tables.TeamsTable.TEAMS_TABLE
import ch.boosters.data.tables.pojos.EventsTable
import ch.boosters.data.tables.pojos.SportsTable
import ch.boosters.data.tables.pojos.TeamsTable
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class SportsRepository(
    private val dsl: JooqEitherDsl
) {
    private val sports = Tables.SPORTS_TABLE

    fun allSports(): Either<SynciError, List<SportsTable>> =
        dsl { it.selectFrom(sports).fetch().into(SportsTable::class.java) }

    fun sportIdByName(name: String): SynciEither<UUID?> = either {
        dsl {
            it
                .selectFrom(sports)
                .where(sports.NAME.eq(name))
                .fetchOne()
                ?.get(sports.ID)
        }.bind()
    }

    fun eventsBySports(sportIds: List<UUID>, limit: Int, offset: Int): Either<SynciError, List<EventsTable>> =
        dsl {
            it.selectFrom(Tables.EVENTS_TABLE)
                .where(Tables.EVENTS_TABLE.SPORT_ID.`in`(sportIds))
                .limit(offset, limit)
                .fetch()
                .into(EventsTable::class.java)
        }

    fun eventsBySportsCount(sportIds: List<UUID>): Either<SynciError, Int> =
        dsl {
            it.selectFrom(Tables.EVENTS_TABLE)
                .where(Tables.EVENTS_TABLE.SPORT_ID.`in`(sportIds))
                .count()
        }

    fun getTeamsBySportId(sportId: UUID): Either<SynciError, List<TeamsTable>> =
        dsl {
            it.select(TEAMS_TABLE.asterisk())
                .from(TEAMS_TABLE)
                .join(TEAMS_SPORTS_TABLE)
                .on(TEAMS_SPORTS_TABLE.TEAM_ID.eq(TEAMS_TABLE.ID))
                .where(TEAMS_SPORTS_TABLE.SPORT_ID.eq(sportId))
                .fetchInto(TeamsTable::class.java)
        }
}