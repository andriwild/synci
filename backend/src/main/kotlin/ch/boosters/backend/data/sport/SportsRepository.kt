package ch.boosters.backend.data.sport

import arrow.core.Either
import arrow.core.raise.either
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.backend.errorhandling.SynciError
import ch.boosters.data.tables.EventsTable.Companion.EVENTS_TABLE
import ch.boosters.data.tables.SportsTable.Companion.SPORTS_TABLE
import ch.boosters.data.tables.TeamsSportsTable.Companion.TEAMS_SPORTS_TABLE
import ch.boosters.data.tables.TeamsTable.Companion.TEAMS_TABLE
import ch.boosters.data.tables.pojos.EventsTable
import ch.boosters.data.tables.pojos.SportsTable
import ch.boosters.data.tables.pojos.TeamsTable
import org.jooq.DSLContext
import org.jooq.Record
import org.jooq.SelectConditionStep
import org.springframework.stereotype.Repository
import java.time.LocalDateTime
import java.util.*

@Repository
class SportsRepository(
    private val dsl: JooqEitherDsl
) {
    private val sports = SPORTS_TABLE

    fun allSports(): Either<SynciError, List<SportsTable>> =
        dsl { it.selectFrom(sports)
            .orderBy(SPORTS_TABLE.LABEL)
            .fetch().into(SportsTable::class.java) }

    fun sportIdByName(name: String): SynciEither<UUID?> = either {
        dsl {
            it
                .selectFrom(sports)
                .where(sports.NAME.eq(name))
                .fetchOne()
                ?.get(sports.ID)
        }.bind()
    }

    fun eventsBySports(sportIds: List<UUID>, limit: Int, offset: Int, dateTime: LocalDateTime): Either<SynciError, List<EventsTable>> =
        dsl {
            it.selectFrom(EVENTS_TABLE)
                .where(EVENTS_TABLE.SPORT_ID.`in`(sportIds))
                .and(EVENTS_TABLE.STARTS_ON.greaterOrEqual(dateTime))
                .orderBy(EVENTS_TABLE.STARTS_ON)
                .limit(offset, limit)
                .fetch()
                .into(EventsTable::class.java)
        }

    fun teamsBySportsCount(sportIds: List<UUID>): Either<SynciError, Int> =
        dsl {
            teamsBySport(it, sportIds)
                .count()
        }

    fun eventsBySportsCount(sportIds: List<UUID>, dateTime: LocalDateTime): Either<SynciError, Int> =
        dsl {
            it.selectFrom(EVENTS_TABLE)
                .where(EVENTS_TABLE.SPORT_ID.`in`(sportIds))
                .and(EVENTS_TABLE.STARTS_ON.greaterOrEqual(dateTime))
                .count()
        }

    fun getTeamsBySportIds(sportIds: List<UUID>, limit: Int, offset: Int): Either<SynciError, List<TeamsTable>> =
        dsl {
            teamsBySport(it, sportIds)
                .orderBy(TEAMS_TABLE.NAME)
                .limit(offset, limit)
                .fetchInto(TeamsTable::class.java)
        }

    private fun teamsBySport(
        dsl: DSLContext,
        sportIds: List<UUID>
    ): SelectConditionStep<Record> = dsl.selectDistinct(TEAMS_TABLE.asterisk())
        .from(TEAMS_TABLE)
        .leftJoin(TEAMS_SPORTS_TABLE)
        .on(
            TEAMS_TABLE.ID.eq(TEAMS_SPORTS_TABLE.TEAM_ID).and(TEAMS_TABLE.SOURCE_ID.eq(TEAMS_SPORTS_TABLE.SOURCE_TEAM_ID))
        )
        .where(TEAMS_SPORTS_TABLE.SPORT_ID.`in`(sportIds))
}