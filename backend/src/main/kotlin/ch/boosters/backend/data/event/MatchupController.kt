package ch.boosters.backend.data.event

import arrow.core.raise.either
import ch.boosters.backend.data.sport.model.PagedResult
import ch.boosters.backend.errorhandling.SynciEither
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.time.LocalDateTime

/** Preview of an own Top Event: the upcoming games between two teams. */
@RestController
@RequestMapping("/matchups")
@PreAuthorize("isAuthenticated()")
class MatchupController(private val eventRepository: EventRepository) {

    @GetMapping("/events")
    fun getEvents(
        @RequestParam sourceId: Int,
        @RequestParam teamA: String,
        @RequestParam teamB: String,
        @RequestParam pageSize: Int,
        @RequestParam page: Int,
    ): SynciEither<PagedResult<EventResponse>> = either {
        val now = LocalDateTime.now()
        val amount = eventRepository.upcomingEventsOfMatchupCount(sourceId, teamA, teamB, now).bind()
        val events = eventRepository.upcomingEventsOfMatchup(sourceId, teamA, teamB, pageSize, page * pageSize, now).bind()
        PagedResult(amount, page, pageSize, eventRepository.withTeams(events).bind())
    }
}
