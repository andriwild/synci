package ch.boosters.backend.data.team

import ch.boosters.backend.data.syncConfig.SyncConfig
import ch.boosters.backend.data.syncConfig.SyncConfigService
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController


@RestController
@RequestMapping("/team")
class TeamController(private val teamService: TeamService) {

    @GetMapping("/list")
    fun listConfig(): List<Team> {
        return teamService.getAllTeams()
    }
}