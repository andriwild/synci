package ch.boosters.backend.data.event

import ch.boosters.backend.data.event.model.Event
import ch.boosters.data.Tables.EVENT
import org.jooq.DSLContext
import org.springframework.stereotype.Repository

@Repository
class EventRepository(private val dslContext: DSLContext) {

    fun allEvents(): List<Event> {
        val result = dslContext.select().from(EVENT).fetch()

        return result.map {
            Event(it.getValue(EVENT.NAME), it.getValue(EVENT.ID), it.getValue(EVENT.STARTS_ON), it.getValue(EVENT.ENDS_ON))
        }
    }
}