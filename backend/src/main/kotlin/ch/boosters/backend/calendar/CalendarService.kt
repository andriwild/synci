package ch.boosters.backend.calendar

import arrow.core.raise.either
import ch.boosters.backend.data.event.EventRepository
import ch.boosters.backend.data.organisation.OrganisationMemberRepository
import ch.boosters.backend.data.sport.SportsRepository
import ch.boosters.backend.data.sport.SportsService
import ch.boosters.backend.data.sport.model.flatten
import ch.boosters.backend.data.syncConfig.SyncConfigRepository
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.tables.pojos.EventsTable
import net.fortuna.ical4j.model.Calendar
import org.springframework.stereotype.Service
import java.util.*

@Service
class CalendarService(
    private val eventRepository: EventRepository,
    private val syncConfigRepository: SyncConfigRepository,
    private val sportsService: SportsService,
    private val sportsRepository: SportsRepository,
    private val organisationMemberRepository: OrganisationMemberRepository
) {

    fun createCalendar(configId: UUID): SynciEither<Calendar> = either {
        val config = syncConfigRepository.findSyncConfig(configId).bind()
        val sportEvents = eventsBySport(configId).bind()
        val teamEvents = eventRepository.eventsOfTeams(configId).bind()
        val events = eventRepository.eventsByConfig(configId).bind()

        // organisation events only reach the feed while the config owner is an active member;
        // this is checked at read time so leaving an organisation needs no cleanup of the config
        val allowedOrganisations = organisationMemberRepository.activeOrganisationIdsOfConfigOwner(configId).bind().toSet()
        val organisationOfSport = sportsRepository.allSports().bind()
            .filter { it.organisationId != null }
            .associate { it.id to it.organisationId!! }
        fun visible(event: EventsTable): Boolean =
            organisationOfSport[event.sportId]?.let { it in allowedOrganisations } ?: true

        val calendarEvents = (teamEvents + sportEvents + events)
            .filter(::visible)
            .map { it.toCalendarEvent() }
        CalendarBuilder.build(calendarEvents, config.name)
    }

    private fun eventsBySport(configId: UUID): SynciEither<List<EventsTable>> = either {
        val sportsIdsInConfig = eventRepository.sportsByConfig(configId).bind()
        val includingSubSports = sportsIdsInConfig
            .map { sportsService.findSportsByParent(it) }
            .bindAll()
            .flatMap { it.flatten() }
            .distinct()
        eventRepository.eventsBySports(includingSubSports).bind()
    }
}
