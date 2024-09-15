package ch.boosters.backend.data.event

import ch.boosters.backend.data.event.model.Event
import ch.boosters.data.Tables.EVENTS_TABLE
import org.jooq.DSLContext
import org.springframework.stereotype.Repository

@Repository
class EventRepository(private val dslContext: DSLContext) {

    fun allEvents(): List<Event> {
        val result = dslContext.select().from(EVENTS_TABLE).fetch()

        return result.map {
            Event(it.getValue(EVENTS_TABLE.NAME), it.getValue(EVENTS_TABLE.ID), it.getValue(EVENTS_TABLE.STARTS_ON), it.getValue(EVENTS_TABLE.ENDS_ON))
        }
    }
}