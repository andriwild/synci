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
import net.fortuna.ical4j.model.property.Url
import net.fortuna.ical4j.model.property.XProperty
import net.fortuna.ical4j.model.property.immutable.ImmutableCalScale
import net.fortuna.ical4j.model.property.immutable.ImmutableVersion
import java.net.URI
import java.time.ZoneId

const val PROD_ID = "-//Events Calendar//iCal4j 1.0//EN"
const val CALENDAR_TIME_ZONE = "Europe/Zurich"

/** Pure ICS assembly, kept free of repositories so it can be unit-tested. */
object CalendarBuilder {

    fun build(events: List<CalendarEvent>, calendarName: String): Calendar {
        val timeZoneRegistry = TimeZoneRegistryFactory.getInstance().createRegistry()
        val timeZone = timeZoneRegistry.getTimeZone(CALENDAR_TIME_ZONE)
        val icsCalendar = Calendar()
        icsCalendar.add<PropertyContainer>(Name("Synci - $calendarName"))
        // Google Calendar ignores NAME and takes its name and time zone only from these
        icsCalendar.add<PropertyContainer>(XProperty("X-WR-CALNAME", "Synci - $calendarName"))
        icsCalendar.add<PropertyContainer>(XProperty("X-WR-TIMEZONE", CALENDAR_TIME_ZONE))
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
            // event times are Swiss local time; without a TZID they float and Google reads them as UTC
            val zone = ZoneId.of(CALENDAR_TIME_ZONE)
            VEvent(event.startsOn.atZone(zone), event.endsOn.atZone(zone), event.name)
        }
        vEvent.add<PropertyContainer>(Uid("${event.id}@synci.ch"))
        event.location?.takeIf { it.isNotBlank() }?.let { vEvent.add<PropertyContainer>(Location(it)) }
        val description = listOfNotNull(
            event.description?.takeIf { it.isNotBlank() },
            event.responseUrl?.let { "Zu- oder absagen: $it" }
        )
        if (description.isNotEmpty()) vEvent.add<PropertyContainer>(Description(description.joinToString("\n\n")))
        // Apple Calendar shows URL as a link; Google ignores it, hence also the line in the description
        event.responseUrl?.let { vEvent.add<PropertyContainer>(Url(URI(it))) }
        return vEvent
    }
}
