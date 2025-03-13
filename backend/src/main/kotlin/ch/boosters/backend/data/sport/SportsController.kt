package ch.boosters.backend.data.sport

import arrow.core.Either
import ch.boosters.backend.data.sport.model.EventsBySportApi
import ch.boosters.backend.data.sport.model.Sport
import ch.boosters.backend.data.team.TeamService
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.backend.errorhandling.SynciError
import ch.boosters.data.tables.pojos.TeamsTable
import org.springframework.web.bind.annotation.*
import java.util.*

@RestController
@RequestMapping("/sports")
class SportsController (
    private val sportsService: SportsService,
    private val teamService: TeamService
) {
    @GetMapping("")
    fun getAll(): Either<SynciError, List<Sport>> =
        sportsService.findSports()

    @GetMapping("/{id}/events")
    fun getEventsBySport(
        @PathVariable id: UUID,
        @RequestParam pageSize: Int,
        @RequestParam page: Int
    ): Either<SynciError, EventsBySportApi> =
        sportsService.getEventsBySport(id, pageSize, page)

    @GetMapping("/{id}/teams")
    fun getTeamsBySport(
        @PathVariable id: UUID,
    ): SynciEither<List<TeamsTable>> =
        teamService.getTeamsBySportId(id)
}