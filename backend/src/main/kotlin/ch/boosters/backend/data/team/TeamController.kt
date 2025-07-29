package ch.boosters.backend.data.team

import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.tables.pojos.TeamsTable
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController


@RestController
@RequestMapping("/teams")
class TeamController(private val teamService: TeamService) {

    @GetMapping("")
    fun listConfig(): SynciEither<List<TeamsTable>> = teamService.getAllTeams()


}