package ch.boosters.backend.data.event

import ch.boosters.data.Tables.EVENT
import org.jooq.DSLContext
import org.springframework.stereotype.Repository

@Repository
class EventRepository(private val dslContext: DSLContext) {

    fun allEvents(): List<String> {
        val result = dslContext.select().from(EVENT).fetch()

        return result.map { it.getValue(EVENT.NAME) }
    }
}