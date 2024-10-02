package ch.boosters.backend.calendar

import ch.boosters.backend.data.event.EventRepository
import net.fortuna.ical4j.model.Calendar
import net.fortuna.ical4j.model.ComponentContainer
import net.fortuna.ical4j.model.PropertyContainer
import net.fortuna.ical4j.model.component.CalendarComponent
import net.fortuna.ical4j.model.component.VEvent
import net.fortuna.ical4j.model.property.ProdId
import net.fortuna.ical4j.model.property.immutable.ImmutableCalScale
import org.springframework.stereotype.Service

@Service
class CalendarService(private val eventRepository: EventRepository) {

    fun createCalendar(): String {
        val icsCalendar = Calendar()
        icsCalendar.add<PropertyContainer>(ProdId("-//Events Calendar//iCal4j 1.0//EN"))
        icsCalendar.add<PropertyContainer>(ImmutableCalScale.GREGORIAN)

        val events = eventRepository.allEvents()
        events.map {
            val meeting = VEvent(it.startsOn, it.endsOn, it.name)
            icsCalendar.add<ComponentContainer<CalendarComponent>>(meeting)
        }

        return icsCalendar.toString()
    }

    fun createCalendar(teamId: String): String {
        val icsCalendar = Calendar()
        icsCalendar.add<PropertyContainer>(ProdId("-//Events Calendar//iCal4j 1.0//EN"))
        icsCalendar.add<PropertyContainer>(ImmutableCalScale.GREGORIAN)

        val events = eventRepository.eventsOfTeam(teamId)
        events.map {
            val meeting = VEvent(it.startsOn, it.endsOn, it.name)
            icsCalendar.add<ComponentContainer<CalendarComponent>>(meeting)
        }

        return icsCalendar.toString()
    }
}
