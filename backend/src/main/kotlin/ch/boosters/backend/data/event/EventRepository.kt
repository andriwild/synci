package ch.boosters.backend.data.event

import ch.boosters.backend.data.event.model.Event
import ch.boosters.data.Tables.*
import org.jooq.DSLContext
import org.jooq.exception.DataAccessException
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class EventRepository(private val dsl: DSLContext) {

    fun clearTable(): Boolean {
        try {
            dsl.truncate(EVENTS_TABLE).cascade().execute()
            dsl.truncate(EVENTS_TEAMS_TABLE).cascade().execute()
        } catch (e: DataAccessException) {
            return false
        }
        return true
    }

    fun eventsOfTeam(configID: UUID) : List<Event> {
        val teamIds = dsl.selectFrom(SYNC_CONFIGS_TEAMS_TABLE)
            .where(SYNC_CONFIGS_TEAMS_TABLE.SYNC_CONFIG_ID.eq(configID))
            .fetch()

        val e = EVENTS_TABLE
        val et = EVENTS_TEAMS_TABLE

        val result = teamIds.map { team ->
            dsl.select()
                .from(e)
                .join(et)
                .on(e.ID.eq(et.EVENT_ID))
                .where(et.TEAM_ID.eq(team.teamId))
                .fetch()
                .map {
                    Event(
                        it.getValue(EVENTS_TABLE.NAME),
                        it.getValue(EVENTS_TABLE.ID),
                        it.getValue(EVENTS_TABLE.STARTS_ON),
                        it.getValue(EVENTS_TABLE.ENDS_ON)
                    )
                }
        }
        return result.flatten()
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
