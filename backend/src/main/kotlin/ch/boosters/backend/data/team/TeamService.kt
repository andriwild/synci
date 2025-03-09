package ch.boosters.backend.data.team

import ch.boosters.backend.errorhandling.SynciEither
import org.springframework.stereotype.Service

@Service
class TeamService(private val teamRepository: TeamRepository) {

    fun getAllTeams(): SynciEither<List<Team>> =
        teamRepository.getAllTeams()
}