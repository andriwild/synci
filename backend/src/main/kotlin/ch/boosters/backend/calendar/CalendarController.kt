package ch.boosters.backend.calendar

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.util.*

@RestController
@RequestMapping("/calendar")
class CalendarController(private val calendarService: CalendarService) {

    @GetMapping("/subscribe/{configId}", produces = ["text/calendar"])
    fun createCalendarFromTeam(@PathVariable configId: UUID): String {
        return calendarService.createCalendar(configId).toString()
    }
}