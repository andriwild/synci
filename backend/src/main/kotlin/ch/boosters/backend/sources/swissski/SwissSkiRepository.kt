package ch.boosters.backend.sources.swissski

import arrow.core.Either
import arrow.core.raise.either
import ch.boosters.backend.errorhandling.DatabaseError
import ch.boosters.backend.errorhandling.safeDbOp
import ch.boosters.backend.sources.swissski.model.SwissSkiEvent
import ch.boosters.data.Tables.*
import org.jooq.DSLContext
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class SwissSkiRepository(
    private val dsl: DSLContext,
    private val swissSkiConfig: SwissSkiConfig,
) {

    val sourceId: Int by lazy {
        initSourceId()
    }

    fun storeEvents(events: List<SwissSkiEvent>): Either<DatabaseError, List<Int>> = either {
        events
            .map { Pair(it, findSportId(it)) }
            .filter { it.second.bind() != null }
            .map { storeEvent(it.first, it.second.bind()!!) }
    }

    private fun storeEvent(event: SwissSkiEvent, sportId: UUID): Int {
        return dsl.newRecord(EVENTS_TABLE)
            .setId(UUID.randomUUID().toString())
            .setName(event.place)
            .setSourceId(sourceId)
            .setStartsOn(event.raceDate)
            .setSportId(sportId)
            .store()
    }

    private fun initSourceId(): Int {
        val id = dsl.select()
            .from(SOURCES_TABLE)
            .where(SOURCES_TABLE.NAME.eq(swissSkiConfig.name))
            .fetchOne(SOURCES_TABLE.ID)
        return id!!
    }

    private fun findSportId(event: SwissSkiEvent): Either<DatabaseError, UUID?> {
        val sportsName = "${event.catCode}_${event.disciplineCode}_${event.gender}"
        return Either.safeDbOp{
            dsl.select()
                .from(SPORTS_TABLE)
                .where(SPORTS_TABLE.NAME.eq(sportsName))
                .fetchOne(SPORTS_TABLE.ID)
        }

    }
}