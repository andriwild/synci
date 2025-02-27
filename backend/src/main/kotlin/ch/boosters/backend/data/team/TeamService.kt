package ch.boosters.backend.data.team

import org.springframework.stereotype.Service

@Service
class TeamService (private val teamRepository: TeamRepository) {

    fun getAllTeams(): List<Team> {
        return teamRepository.getAllTeams()
    }

}