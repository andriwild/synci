package ch.boosters.backend

import ch.boosters.backend.data.event.EventRepository
import ch.boosters.backend.data.event.model.Event
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

@RestController
class MainController(val repository: EventRepository) {

  @GetMapping("/")
  fun greeting(@RequestParam name: String?): String  {
    return "hello $name"
  }

  @GetMapping("/events")
  fun allEvents(): List<Event>  {
    val events = repository.allEvents()
    return events
  }
}