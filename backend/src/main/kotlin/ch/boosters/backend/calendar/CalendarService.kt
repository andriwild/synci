package ch.boosters.backend.calendar

import net.fortuna.ical4j.model.*
import net.fortuna.ical4j.model.Calendar
import net.fortuna.ical4j.model.component.CalendarComponent
import net.fortuna.ical4j.model.component.VEvent
import net.fortuna.ical4j.model.parameter.Cn
import net.fortuna.ical4j.model.parameter.Role
import net.fortuna.ical4j.model.property.Attendee
import net.fortuna.ical4j.model.property.ProdId
import net.fortuna.ical4j.model.property.immutable.ImmutableCalScale
import net.fortuna.ical4j.model.property.immutable.ImmutableVersion
import net.fortuna.ical4j.util.RandomUidGenerator
import org.springframework.stereotype.Service
import java.net.URI
import java.time.Instant
import java.time.temporal.ChronoUnit
import java.util.*

@Service
class CalendarService {

    fun createCalendar(): String {
        val calendar = Calendar()
        calendar.add<PropertyContainer>(ProdId("-//Ben Fortuna//iCal4j 1.0//EN"))
        calendar.add<PropertyContainer>(ImmutableVersion.VERSION_2_0)
        calendar.add<PropertyContainer>(ImmutableCalScale.GREGORIAN)

        val registry = TimeZoneRegistryFactory.getInstance().createRegistry()
        val timezone = registry.getTimeZone("America/Mexico_City")
        //Timezone currently not working: Type-Error occurs
        //val tz = timezone.vTimeZone

        // Start Date is on: April 1, 2008, 9:00 am
        val startDate: java.util.Calendar = GregorianCalendar()
        startDate.timeZone = timezone
        startDate[java.util.Calendar.MONTH] = java.util.Calendar.OCTOBER
        startDate[java.util.Calendar.DAY_OF_MONTH] = 1
        startDate[java.util.Calendar.YEAR] = 2024
        startDate[java.util.Calendar.HOUR_OF_DAY] = 9
        startDate[java.util.Calendar.MINUTE] = 0
        startDate[java.util.Calendar.SECOND] = 0

        // End Date is on: April 1, 2008, 13:00
        val endDate: java.util.Calendar = GregorianCalendar()
        endDate.timeZone = timezone
        endDate[java.util.Calendar.MONTH] = java.util.Calendar.OCTOBER
        endDate[java.util.Calendar.DAY_OF_MONTH] = 1
        endDate[java.util.Calendar.YEAR] = 2024
        endDate[java.util.Calendar.HOUR_OF_DAY] = 13
        endDate[java.util.Calendar.MINUTE] = 0
        endDate[java.util.Calendar.SECOND] = 0

        val eventName = "Progress Meeting"
        val start = Instant.now();
        val end = Instant.now().plus(100L, ChronoUnit.MINUTES)
        val meeting: VEvent = VEvent(start, end, eventName)

        //meeting.add(tz.timeZoneId)

        val ug = RandomUidGenerator()
        val uid = ug.generateUid()
        meeting.add<PropertyContainer>(uid)

        val dev1 = Attendee(URI.create("mailto:dev1@mycompany.com"))
        dev1.add<Property>(Role.REQ_PARTICIPANT)
        dev1.add<Property>(Cn("Developer 1"))
        meeting.add<PropertyContainer>(dev1)

        val dev2 = Attendee(URI.create("mailto:dev2@mycompany.com"))
        dev2.add<Property>(Role.OPT_PARTICIPANT)
        dev2.add<Property>(Cn("Developer 2"))
        meeting.add<PropertyContainer>(dev2)

        val icsCalendar = Calendar()
        icsCalendar.add<PropertyContainer>(ProdId("-//Events Calendar//iCal4j 1.0//EN"))
        icsCalendar.add<PropertyContainer>(ImmutableCalScale.GREGORIAN)

        icsCalendar.add<ComponentContainer<CalendarComponent>>(meeting)

        return icsCalendar.toString()
    }
}