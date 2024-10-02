package ch.boosters.backend.calendar

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/calendar")
class CalendarController(private val calendarService: CalendarService) {

    @GetMapping("/subscribe", produces = ["text/calendar"])
    fun createCalendar(): String {
        return calendarService.createCalendar()
    }

    @GetMapping("/subscribe/{teamId}", produces = ["text/calendar"])
    fun createCalendarFromTeam(@PathVariable teamId: String): String {
        return calendarService.createCalendar(teamId)
    }
}
