package ch.boosters.backend.calendar

import ch.boosters.backend.errorhandling.ErrorHandler
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.util.*

@RestController
@RequestMapping("/calendars")
class CalendarController(private val calendarService: CalendarService) {

    @GetMapping("/{configId}/subscribe", produces = ["text/calendar"])
    fun createCalendarFromTeam(@PathVariable configId: UUID): ResponseEntity<String> =
        calendarService.createCalendar(configId).fold(
            { ErrorHandler.handle(it) },
            { ResponseEntity.ok(it.toString()) }
        )
}
