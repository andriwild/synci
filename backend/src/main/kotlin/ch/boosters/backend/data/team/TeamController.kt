package ch.boosters.backend.data.team

import ch.boosters.backend.data.syncConfig.SyncConfig
import ch.boosters.backend.data.syncConfig.SyncConfigService
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController


@RestController
@RequestMapping("/team")
class TeamController(private val teamService: TeamService) {
//    @PreAuthorize("hasAnyRole('USER')")
    @GetMapping("/list")
    fun listConfig(): List<Team> {
        return teamService.getAllTeams()
    }
}