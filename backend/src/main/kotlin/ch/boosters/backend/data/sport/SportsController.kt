package ch.boosters.backend.data.sport

import arrow.core.Either
import ch.boosters.backend.errorhandling.SynciError
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/sports")
class SportsController (
    private val sportsService: SportService
) {
    @GetMapping("/")
    fun getAll(): Either<SynciError, List<Sport>> =
        sportsService.findSports()
}
