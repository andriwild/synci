package ch.boosters.backend.data.sport

import arrow.core.Either
import arrow.core.raise.either
import arrow.core.raise.ensure
import arrow.core.raise.ensureNotNull
import ch.boosters.backend.auth.CurrentUserResolver
import ch.boosters.backend.data.organisation.OrganisationAccess
import ch.boosters.backend.data.sport.business.findSportsByParent
import ch.boosters.backend.data.sport.business.groupByRootSports
import ch.boosters.backend.data.sport.model.PagedResult
import ch.boosters.backend.data.sport.model.Sport
import ch.boosters.backend.data.sport.model.flatten
import ch.boosters.backend.errorhandling.ElementNotFound
import ch.boosters.backend.errorhandling.Forbidden
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.backend.errorhandling.SynciError
import ch.boosters.data.tables.pojos.EventsTable
import ch.boosters.data.tables.pojos.SportsTable
import ch.boosters.data.tables.pojos.TeamsTable
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Service
import java.time.LocalDateTime
import java.util.*

@Service
class SportsService(
    private val sportRepository: SportsRepository,
    private val organisationAccess: OrganisationAccess,
    private val currentUserResolver: CurrentUserResolver
) {
    fun findSportsByParent(parent: UUID): Either<SynciError, Sport> = either {
        val allSports: List<SportsTable> = sportRepository.allSports().bind()
        val sport = allSports.findSportsByParent(parent)
        ensure (sport != null){ ElementNotFound("Could not find sports with id: $parent") }
        sport
    }

    /** Public tree without organisations. */
    fun findSports(): Either<SynciError, List<Sport>> = either {
        val sports: List<SportsTable> = sportRepository.publicSports().bind()
        sports.groupByRootSports()
    }

    fun getEventsBySport(
        sportId: UUID,
        pageSize: Int,
        pageNumber: Int,
        dateTime: LocalDateTime,
        authentication: Authentication?
    ): SynciEither<PagedResult<EventsTable>> = either {
        requireAccess(sportId, authentication).bind()
        val allIds = findSportsByParent(sportId).bind().flatten()
        val eventsCount = sportRepository.eventsBySportsCount(allIds, dateTime).bind()
        val elements = sportRepository.eventsBySports(allIds, pageSize, pageNumber * pageSize, dateTime).bind()
        PagedResult(eventsCount, pageNumber, pageSize, elements)
    }

    fun getTeamsBySportId(sportId: UUID, pageSize: Int, pageNumber: Int, searchTerm: String? = null): SynciEither<PagedResult<TeamsTable>> = either {
        val belonging = findSportsByParent(sportId).bind().flatten()
        val teamsCount = sportRepository.teamsBySportsCount(belonging, searchTerm).bind()
        val elements = sportRepository.getTeamsBySportIds(belonging, pageSize, pageNumber * pageSize, searchTerm).bind()
        PagedResult(teamsCount, pageNumber, pageSize, elements)
    }

    /** Sports of an organisation are only visible to its active members; everything else is public. */
    private fun requireAccess(sportId: UUID, authentication: Authentication?): SynciEither<Unit> = either {
        val sport = sportRepository.sportById(sportId).bind()
        ensureNotNull(sport) { ElementNotFound("Could not find sports with id: $sportId") }
        val organisationId = sport.organisationId ?: return@either
        ensureNotNull(authentication) { Forbidden("Nur Mitglieder sehen die Events dieser Organisation") }
        val userId = currentUserResolver.getUserId(authentication)
            .mapLeft { Forbidden("Nur Mitglieder sehen die Events dieser Organisation") }
            .bind()
        organisationAccess.requireActiveMember(organisationId, userId).bind()
    }
}
