package ch.boosters.backend.data.team

import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.tables.pojos.TeamsTable
import org.springframework.stereotype.Service

@Service
class TeamService(
    private val teamRepository: TeamRepository,
) {
    fun getAllTeams(): SynciEither<List<TeamsTable>> = teamRepository.getAllTeams()
}