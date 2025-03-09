package ch.boosters.backend.data.sport

import arrow.core.Either
import arrow.core.raise.either
import ch.boosters.backend.errorhandling.SynciError
import ch.boosters.backend.errorhandling.safeDbOp
import ch.boosters.data.Tables
import ch.boosters.data.tables.pojos.EventsTable
import ch.boosters.data.tables.pojos.SportsTable
import org.jooq.DSLContext
import org.jooq.impl.DSL.*
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class SportsRepository(
    private val dsl: DSLContext
) {

    private val skiAlpineRootName = "SKI_ALPINE"
    private val sports = Tables.SPORTS_TABLE

    fun sportById(id: UUID): SportsTable? {
        return dsl
            .select(sports)
            .from(sports)
            .where(sports.ID.eq(id))
            .fetchOneInto(SportsTable::class.java)
    }

    fun subcategoriesById(rootId: UUID): List<SportsTable> {
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

        val sportsList: List<SportsTable> = dsl
            .withRecursive(descendants)
            .selectFrom(descendants)
            .where(field(name("descendants", "id"), UUID::class.java).ne(rootId))
            .fetchInto(SportsTable::class.java)

        val rootSport = sportById(rootId)
        return if (rootSport == null) sportsList else sportsList.plus(rootSport)
    }

    fun allSports(): Either<SynciError, List<SportsTable>> =
        Either.safeDbOp {
            dsl.selectFrom(sports).fetch().into(SportsTable::class.java)
        }

    fun eventsBySports(sportIds: List<UUID>, limit: Int, offset: Int): Either<SynciError, List<EventsTable>> =
        Either.safeDbOp {
            dsl
                .selectFrom(Tables.EVENTS_TABLE)
                .where(Tables.EVENTS_TABLE.SPORT_ID.`in`(sportIds))
                .limit(offset, limit)
                .fetch()
                .into(EventsTable::class.java)
        }

    fun eventsBySportsCount(sportIds: List<UUID>): Either<SynciError, Int> = either {
        dsl.selectFrom(Tables.EVENTS_TABLE)
            .where(Tables.EVENTS_TABLE.SPORT_ID.`in`(sportIds))
            .count()
    }
}