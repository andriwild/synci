package ch.boosters.backend.sources.fotmob

import ch.boosters.backend.sources.SourceConfig
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import reactor.core.publisher.Mono

@RestController
@RequestMapping("/fotmob")
class FotMobController (val fotMobService: FotMobService, val config: SourceConfig) {

    @GetMapping("/{leagueId}")
    fun getLeagueEvents(@PathVariable leagueId: String): Mono<IntArray> {
        val leagueOverview = fotMobService.fetchLeagueOverview(leagueId)
        return leagueOverview
    }

    @GetMapping("/config")
    fun getConfig(): Map<String, Any?> {
        val config = config.fotmob
        val leagues = config.leagues.map { league ->
            mapOf("id" to league.id, "name" to league.name)
        }
        return mapOf(
            "name" to config.name,
            "url" to config.url,
            "leagues" to leagues
        )
    }
}
