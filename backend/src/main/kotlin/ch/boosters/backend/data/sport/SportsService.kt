package ch.boosters.backend.data.sport

import arrow.core.Either
import arrow.core.raise.either
import arrow.core.raise.ensure
import ch.boosters.backend.data.sport.business.findSportsByParent
import ch.boosters.backend.data.sport.business.groupByRootSports
import ch.boosters.backend.data.sport.model.PagedResult
import ch.boosters.backend.data.sport.model.Sport
import ch.boosters.backend.data.sport.model.flatten
import ch.boosters.backend.errorhandling.ElementNotFound
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.backend.errorhandling.SynciError
import ch.boosters.data.tables.pojos.EventsTable
import ch.boosters.data.tables.pojos.SportsTable
import ch.boosters.data.tables.pojos.TeamsTable
import org.springframework.stereotype.Service
import java.util.*

@Service
class SportsService(
    private val sportRepository: SportsRepository,
) {
    fun findSportsByParent(parent: UUID): Either<SynciError, Sport> = either {
        val allSports: List<SportsTable> = sportRepository.allSports().bind()
        val sport = allSports.findSportsByParent(parent)
        ensure (sport != null){ ElementNotFound("Could not find sports with id: $parent") }
        sport
    }

    fun findSports(): Either<SynciError, List<Sport>> = either {
        val sports: List<SportsTable> = sportRepository.allSports().bind()
        sports.groupByRootSports()
    }

    fun getEventsBySport(sportId: UUID, pageSize: Int, pageNumber: Int): SynciEither<PagedResult<EventsTable>> = either {
        val allIds = findSportsByParent(sportId).bind().flatten()
        val eventsCount = sportRepository.eventsBySportsCount(allIds).bind()
        val elements = sportRepository.eventsBySports(allIds, pageSize, pageNumber * pageSize).bind()
        PagedResult(eventsCount, pageNumber, pageSize, elements)
    }

    fun getTeamsBySportId(sportId: UUID, pageSize: Int, pageNumber: Int): SynciEither<PagedResult<TeamsTable>> = either {
        val belonging = findSportsByParent(sportId).bind().flatten()
        val teamsCount = sportRepository.teamsBySportsCount(belonging).bind()
        val elements = sportRepository.getTeamsBySportIds(belonging, pageSize, pageNumber * pageSize).bind()
        PagedResult(teamsCount, pageNumber, pageSize, elements)
    }
}