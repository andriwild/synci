package ch.boosters.backend.calendar

import arrow.core.Either
import ch.boosters.backend.errorhandling.SynciEither
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.util.*

@RestController
@RequestMapping("/calendars")
class CalendarController(private val calendarService: CalendarService) {

    @GetMapping("/{configId}/subscribe", produces = ["text/calendar"])
    fun createCalendarFromTeam(@PathVariable configId: UUID): String {
        val cal = calendarService.createCalendar(configId)
        // TODO: return either here, somehow this is not working right now...
        return when (cal) {
            is Either.Left -> throw Exception("could not create calendar file")
            is Either.Right -> cal.value.toString()
        }
    }
}