package ch.boosters.backend.data.team

import ch.boosters.backend.data.syncConfig.model.TeamDto
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.tables.pojos.SportsTable
import ch.boosters.data.tables.pojos.TeamsTable
import org.springframework.stereotype.Service
import java.util.UUID

@Service
class TeamService(private val teamRepository: TeamRepository) {
    fun getAllTeams(): SynciEither<List<Team>> =
        teamRepository.getAllTeams()

    fun getTeamsByIds(teamIds: List<TeamDto>): SynciEither<List<TeamsTable>> =
        teamRepository.getTeamsByIds(teamIds)
}