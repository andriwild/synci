package ch.boosters.backend.calendar

import arrow.core.raise.either
import ch.boosters.backend.data.event.EventRepository
import ch.boosters.backend.data.sport.SportsService
import ch.boosters.backend.data.sport.model.flatten
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.tables.pojos.EventsTable
import net.fortuna.ical4j.model.Calendar
import net.fortuna.ical4j.model.ComponentContainer
import net.fortuna.ical4j.model.PropertyContainer
import net.fortuna.ical4j.model.component.CalendarComponent
import net.fortuna.ical4j.model.component.VEvent
import net.fortuna.ical4j.model.property.ProdId
import net.fortuna.ical4j.model.property.Uid
import net.fortuna.ical4j.model.property.immutable.ImmutableCalScale
import org.springframework.stereotype.Service
import java.util.*

const val PROD_ID = "-//Events Calendar//iCal4j 1.0//EN"

@Service
class CalendarService(
    private val eventRepository: EventRepository,
    private val sportsService: SportsService
) {

    fun createCalendar(configId: UUID): SynciEither<Calendar> = either {
        val teamEvents = eventRepository.eventsOfTeams(configId).bind()
        val sportEvents = eventsBySport(configId).bind()
        val events = eventRepository.eventsByConfig(configId).bind()
        toCalendar(teamEvents + sportEvents + events)
    }

    private fun eventsBySport(configId: UUID): SynciEither<List<EventsTable>> = either {
        val sportsIdsInConfig = eventRepository.sportsByConfig(configId).bind()
        val includingSubSports = sportsIdsInConfig
            .map { it -> sportsService.findSportsByParent(it) }
            .bindAll()
            .flatMap { it.flatten() }
            .distinct()
        val eventsBySport = eventRepository.eventsBySports(includingSubSports).bind()
        eventsBySport
    }

    private fun toCalendar(events: List<EventsTable>): Calendar {
        val distinctEvents = events.distinctBy { it.id }
        val icsCalendar = Calendar()
        icsCalendar.add<PropertyContainer>(ProdId(PROD_ID))
        icsCalendar.add<PropertyContainer>(ImmutableCalScale.GREGORIAN)
        distinctEvents.forEach {
            val event: VEvent = if (it.endsOn == null) {
                // TODO: #12 meaningful name for ski events
                VEvent(it.startsOn.toLocalDate(), it.name)
            } else {
                VEvent(it.startsOn, it.endsOn, it.name)
            }
            val uid = it.id
            event.add<PropertyContainer>(Uid(uid))

            icsCalendar.add<ComponentContainer<CalendarComponent>>(event)
        }
        return icsCalendar
    }
}