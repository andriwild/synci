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
    val description: String? = null,
    /** link to answer yes or no, for organisation events that ask for it */
    val responseUrl: String? = null
)

fun EventsTable.toCalendarEvent(responseUrl: String? = null) =
    CalendarEvent(id, name, startsOn, endsOn, location, description, responseUrl)
