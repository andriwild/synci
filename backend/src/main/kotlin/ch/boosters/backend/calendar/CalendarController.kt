package ch.boosters.backend.calendar

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class CalendarController(private val calendarService: CalendarService) {

    @GetMapping("/create-calendar", produces = ["text/calendar"])
    fun createCalendar(): String {
        return calendarService.createCalendar()
    }
}