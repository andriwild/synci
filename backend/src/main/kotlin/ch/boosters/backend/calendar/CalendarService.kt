package ch.boosters.backend.calendar

import ch.boosters.backend.data.event.EventRepository
import ch.boosters.backend.data.syncConfig.SyncConfig
import ch.boosters.backend.data.syncConfig.SyncConfigRepository
import net.fortuna.ical4j.model.Calendar
import net.fortuna.ical4j.model.ComponentContainer
import net.fortuna.ical4j.model.PropertyContainer
import net.fortuna.ical4j.model.component.CalendarComponent
import net.fortuna.ical4j.model.component.VEvent
import net.fortuna.ical4j.model.property.ProdId
import net.fortuna.ical4j.model.property.immutable.ImmutableCalScale
import org.springframework.stereotype.Service
import java.util.UUID

@Service
class CalendarService(private val eventRepository: EventRepository, private val syncConfigRepository: SyncConfigRepository) {
    fun createCalendar(id: UUID): String {
        val currentConfig = syncConfigRepository.getSyncConfigById(id)

        //TODO: search for events by currentConfig -> Teams

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
}