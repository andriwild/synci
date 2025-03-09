package ch.boosters.backend.data.sport

import arrow.core.Either
import ch.boosters.backend.data.sport.model.EventsBySportApi
import ch.boosters.backend.data.sport.model.Sport
import ch.boosters.backend.errorhandling.SynciError
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

@RestController
@RequestMapping("/sports")
class SportsController (
    private val sportsService: SportsService
) {
    @GetMapping("/")
    fun getAll(): Either<SynciError, List<Sport>> =
        sportsService.findSports()

    @GetMapping("/{id}/events")
    fun getEventsBySport(
        @PathVariable id: UUID,
        @RequestParam pageSize: Int,
        @RequestParam page: Int
    ): Either<SynciError, EventsBySportApi> =
        sportsService.getEventsBySport(id, pageSize, page)
}
