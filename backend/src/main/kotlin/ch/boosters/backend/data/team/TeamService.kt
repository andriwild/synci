package ch.boosters.backend.data.team

import arrow.core.raise.either
import ch.boosters.backend.data.team.teamSports.TeamSportsRepository
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.tables.pojos.TeamsTable
import org.springframework.stereotype.Service
import java.util.*

@Service
class TeamService(
    private val teamRepository: TeamRepository,
    private val teamSportsRepository: TeamSportsRepository
) {
    fun getAllTeams(): SynciEither<List<Team>> =
        teamRepository.getAllTeams()

    fun getTeamsBySportId(sportId: UUID): SynciEither<List<TeamsTable>>  = either {
        val teams = teamSportsRepository.getTeamsBySportId(sportId).bind()
        teamRepository.getTeamsByIds(teams).bind()
    }
}