package ch.boosters.backend.calendar

import net.fortuna.ical4j.model.Calendar
import net.fortuna.ical4j.model.ComponentContainer
import net.fortuna.ical4j.model.PropertyContainer
import net.fortuna.ical4j.model.TimeZoneRegistryFactory
import net.fortuna.ical4j.model.component.CalendarComponent
import net.fortuna.ical4j.model.component.VEvent
import net.fortuna.ical4j.model.property.Description
import net.fortuna.ical4j.model.property.Location
import net.fortuna.ical4j.model.property.Name
import net.fortuna.ical4j.model.property.ProdId
import net.fortuna.ical4j.model.property.Uid
import net.fortuna.ical4j.model.property.immutable.ImmutableCalScale
import net.fortuna.ical4j.model.property.immutable.ImmutableVersion

const val PROD_ID = "-//Events Calendar//iCal4j 1.0//EN"
const val CALENDAR_TIME_ZONE = "Europe/Zurich"

/** Pure ICS assembly, kept free of repositories so it can be unit-tested. */
object CalendarBuilder {

    fun build(events: List<CalendarEvent>, calendarName: String): Calendar {
        val timeZoneRegistry = TimeZoneRegistryFactory.getInstance().createRegistry()
        val timeZone = timeZoneRegistry.getTimeZone(CALENDAR_TIME_ZONE)
        val icsCalendar = Calendar()
        icsCalendar.add<PropertyContainer>(Name("Synci - $calendarName"))
        icsCalendar.add<PropertyContainer>(ProdId(PROD_ID))
        icsCalendar.add<PropertyContainer>(ImmutableVersion.VERSION_2_0)
        icsCalendar.add<PropertyContainer>(ImmutableCalScale.GREGORIAN)
        icsCalendar.add<ComponentContainer<CalendarComponent>>(timeZone.vTimeZone)
        events.distinctBy { it.id }.forEach { event ->
            icsCalendar.add<ComponentContainer<CalendarComponent>>(toVEvent(event))
        }
        return icsCalendar
    }

    private fun toVEvent(event: CalendarEvent): VEvent {
        val vEvent: VEvent = if (event.endsOn == null) {
            VEvent(event.startsOn.toLocalDate(), event.name)
        } else {
            VEvent(event.startsOn, event.endsOn, event.name)
        }
        vEvent.add<PropertyContainer>(Uid("${event.id}@synci.ch"))
        event.location?.takeIf { it.isNotBlank() }?.let { vEvent.add<PropertyContainer>(Location(it)) }
        event.description?.takeIf { it.isNotBlank() }?.let { vEvent.add<PropertyContainer>(Description(it)) }
        return vEvent
    }
}
