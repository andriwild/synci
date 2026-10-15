package ch.boosters.backend.calendar

import ch.boosters.data.tables.pojos.EventsTable
import java.time.LocalDateTime

/** Source-independent shape of a calendar entry. */
data class CalendarEvent(
    val id: String,
    val name: String,
    val startsOn: LocalDateTime,
    /** null = all-day event */
    val endsOn: LocalDateTime?,
    val location: String? = null,
    val description: String? = null
)

fun EventsTable.toCalendarEvent() = CalendarEvent(id, name, startsOn, endsOn, location, description)
