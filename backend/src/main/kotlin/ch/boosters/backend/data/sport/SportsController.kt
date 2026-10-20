package ch.boosters.backend.data.sport

import arrow.core.Either
import ch.boosters.backend.data.sport.model.PagedResult
import ch.boosters.backend.data.sport.model.Sport
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.backend.errorhandling.SynciError
import ch.boosters.data.tables.pojos.EventsTable
import ch.boosters.backend.data.team.TeamResponse
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*
import java.time.LocalDateTime
import java.util.*

@RestController
@RequestMapping("/sports")
class SportsController(
    private val sportsService: SportsService,
) {
    @GetMapping("")
    fun getAll(): Either<SynciError, List<Sport>> =
        sportsService.findSports()

    @GetMapping("/{id}/events")
    fun getEventsBySport(
        @PathVariable id: UUID,
        @RequestParam pageSize: Int,
        @RequestParam page: Int,
        @RequestParam dateTime: LocalDateTime = LocalDateTime.now(),
        authentication: Authentication?
    ): Either<SynciError, PagedResult<EventsTable>> =
        sportsService.getEventsBySport(id, pageSize, page, dateTime, authentication)

    @GetMapping("/{id}/teams")
    fun getTeamsBySport(
        @PathVariable id: UUID,
        @RequestParam pageSize: Int,
        @RequestParam page: Int,
        @RequestParam(required = false) searchTerm: String?
    ): SynciEither<PagedResult<TeamResponse>> =
        sportsService.getTeamsBySportId(id, pageSize, page, searchTerm)
}