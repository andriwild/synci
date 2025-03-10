package ch.boosters.backend.data.sport

import arrow.core.Either
import arrow.core.raise.either
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.errorhandling.DatabaseError
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.backend.errorhandling.SynciError
import ch.boosters.data.Tables
import ch.boosters.data.tables.pojos.EventsTable
import ch.boosters.data.tables.pojos.SportsTable
import org.jooq.impl.DSL.*
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class SportsRepository(
    private val dsl: JooqEitherDsl
) {

    private val sports = Tables.SPORTS_TABLE

    fun sportById(id: UUID): Either<DatabaseError, SportsTable?> =
        dsl {
            it.select(sports)
                .from(sports)
                .where(sports.ID.eq(id))
                .fetchOneInto(SportsTable::class.java)
        }

    fun sportsById(id: List<UUID>): SynciEither<List<SportsTable>> =
        dsl {
            it.selectFrom(sports)
                .where(sports.ID.`in`(id))
                .fetchInto(SportsTable::class.java)
        }

    fun subcategoriesById(rootId: UUID): Either<DatabaseError, List<SportsTable>> = either {
        val descendants = name("descendants").fields("id", "name", "parent_id").`as`(
            select(sports.ID, sports.NAME, sports.PARENT_ID)
                .from(sports)
                .where(sports.ID.eq(rootId))
                .unionAll(
                    select(sports.ID, sports.NAME, sports.PARENT_ID)
                        .from(sports)
                        .join(table(name("descendants")))
                        .on(sports.PARENT_ID.eq(field(name("descendants", "id"), UUID::class.java)))
                )
        )

        val sportsList = dsl {
            it.withRecursive(descendants)
                .selectFrom(descendants)
                .where(field(name("descendants", "id"), UUID::class.java).ne(rootId))
                .fetchInto(SportsTable::class.java)
        }.bind()

        val rootSport = sportById(rootId).bind()
        if (rootSport == null) sportsList else sportsList.plus(rootSport)
    }

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