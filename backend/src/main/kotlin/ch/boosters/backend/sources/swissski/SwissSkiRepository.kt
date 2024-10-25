package ch.boosters.backend.sources.swissski

import ch.boosters.backend.sources.swissski.model.SwissSkiEvent
import ch.boosters.data.Tables.*
import org.jooq.DSLContext
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class SwissSkiRepository(
    private val dsl: DSLContext,
    private val swissSkiConfig: SwissSkiConfig,
    ){

    val sourceId :Int by lazy {
        initSourceId()
    }

    fun storeEvents(events: List<SwissSkiEvent>) {
        events.forEach { event ->
            val sportId = getSportId(event)
            // skip events of not subscribed sports
            if (sportId != null) {
                storeEvent(event, sportId)
            }
        }
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

    private fun getSportId(event: SwissSkiEvent): UUID? {
        val sportsName = "${event.catCode}_${event.disciplineCode}_${event.gender}"
        return dsl.select()
            .from(SPORTS_TABLE)
            .where(SPORTS_TABLE.NAME.eq(sportsName))
            .fetchOne(SPORTS_TABLE.ID)
    }
}