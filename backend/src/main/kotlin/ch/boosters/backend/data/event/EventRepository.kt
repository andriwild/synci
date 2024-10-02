package ch.boosters.backend.data.event

import ch.boosters.backend.data.event.model.Event
import ch.boosters.data.Tables.EVENTS_TABLE
import ch.boosters.data.Tables.EVENTS_TEAMS_TABLE
import org.jooq.DSLContext
import org.springframework.stereotype.Repository

@Repository
class EventRepository(private val dsl: DSLContext) {

    fun eventsOfTeam(teamId: String) : List<Event> {
        val e = EVENTS_TABLE
        val et = EVENTS_TEAMS_TABLE

        val result = dsl.select()
            .from(e)
            .join(et)
            .on(e.ID.eq(et.EVENT_ID))
            .where(et.TEAM_ID.eq(teamId))
            .fetch()

        return result.map {
            Event(
                it.getValue(EVENTS_TABLE.NAME),
                it.getValue(EVENTS_TABLE.ID),
                it.getValue(EVENTS_TABLE.STARTS_ON),
                it.getValue(EVENTS_TABLE.ENDS_ON)
            )
        }

    }

    fun allEvents(): List<Event> {
        val result = dsl.select().from(EVENTS_TABLE).fetch()

        return result.map {
            Event(
                it.getValue(EVENTS_TABLE.NAME),
                it.getValue(EVENTS_TABLE.ID),
                it.getValue(EVENTS_TABLE.STARTS_ON),
                it.getValue(EVENTS_TABLE.ENDS_ON)
            )
        }
    }
}
