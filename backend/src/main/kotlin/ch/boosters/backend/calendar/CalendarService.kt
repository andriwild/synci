package ch.boosters.backend.calendar

import ch.boosters.backend.data.event.EventRepository
import ch.boosters.backend.data.event.model.Event
import net.fortuna.ical4j.model.Calendar
import net.fortuna.ical4j.model.ComponentContainer
import net.fortuna.ical4j.model.PropertyContainer
import net.fortuna.ical4j.model.component.CalendarComponent
import net.fortuna.ical4j.model.component.VEvent
import net.fortuna.ical4j.model.property.ProdId
import net.fortuna.ical4j.model.property.immutable.ImmutableCalScale
import org.springframework.stereotype.Service

const val PROD_ID = "-//Events Calendar//iCal4j 1.0//EN"

@Service
class CalendarService(private val eventRepository: EventRepository) {

    fun createCalendar(): String {
        val events = eventRepository.allEvents()
        return toCalendar(events).toString()
    }

    fun createCalendar(teamId: String): String {
        val events = eventRepository.eventsOfTeam(teamId)
        return toCalendar(events).toString()
    }

    private fun toCalendar(events: List<Event>): Calendar {
        val icsCalendar = Calendar()
        icsCalendar.add<PropertyContainer>(ProdId(PROD_ID))
        icsCalendar.add<PropertyContainer>(ImmutableCalScale.GREGORIAN)
        events.forEach {
            val event = VEvent(it.startsOn, it.endsOn, it.name)
            icsCalendar.add<ComponentContainer<CalendarComponent>>(event)
        }
        return icsCalendar
    }
}
