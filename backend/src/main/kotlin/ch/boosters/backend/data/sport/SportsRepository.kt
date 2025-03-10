package ch.boosters.backend.data.sport

import arrow.core.Either
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.errorhandling.SynciError
import ch.boosters.data.Tables
import ch.boosters.data.tables.pojos.EventsTable
import ch.boosters.data.tables.pojos.SportsTable
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class SportsRepository(
    private val dsl: JooqEitherDsl
) {
    private val sports = Tables.SPORTS_TABLE

    fun allSports(): Either<SynciError, List<SportsTable>> =
        dsl { it.selectFrom(sports).fetch().into(SportsTable::class.java) }

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
}