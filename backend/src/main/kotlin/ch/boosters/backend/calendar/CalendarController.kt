package ch.boosters.backend.calendar

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

@RestController
class CalendarController(private val calendarService: CalendarService) {

    @GetMapping("/calendar", produces = ["text/calendar"])
    fun createCalendar(@RequestParam("id") id: UUID): String {
        return calendarService.createCalendar(id)
    }
}