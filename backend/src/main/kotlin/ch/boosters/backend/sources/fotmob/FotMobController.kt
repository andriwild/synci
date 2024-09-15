package ch.boosters.backend.sources.fotmob

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import reactor.core.publisher.Mono


@RestController
@RequestMapping("/fotmob")
class FotMobController (val fotMobService: FotMobService) {

    //Todo: add scheduled task to fetch the data
    // Get all leagues form DB

    @GetMapping("/{leagueId}")
    fun getSuperLeagueEvents(@PathVariable leagueId: String): Mono<IntArray> {
        val leagueOverview = fotMobService.fetchLeagueOverview(leagueId)
        println(leagueOverview)
        return leagueOverview
    }

}