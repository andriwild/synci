package ch.boosters.backend.data.organisation

import arrow.core.raise.either
import arrow.core.raise.ensure
import arrow.core.raise.ensureNotNull
import ch.boosters.backend.data.organisation.model.OrganisationEventDto
import ch.boosters.backend.errorhandling.ElementNotFound
import ch.boosters.backend.errorhandling.InvalidRequest
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.tables.pojos.EventsTable
import org.springframework.stereotype.Service
import java.util.UUID

/** Write side for organisation events; reading goes through GET /sports/{id}/events. */
@Service
class OrganisationEventService(
    private val events: OrganisationEventRepository,
    private val groups: OrganisationGroupRepository,
    private val access: OrganisationAccess
) {

    fun create(organisationId: UUID, event: OrganisationEventDto, userId: UUID): SynciEither<EventsTable> = either {
        access.requireAdmin(organisationId, userId).bind()
        val cleaned = validate(organisationId, event).bind()
        events.create(cleaned).bind()
    }

    fun update(organisationId: UUID, eventId: String, event: OrganisationEventDto, userId: UUID): SynciEither<EventsTable> =
        either {
            access.requireAdmin(organisationId, userId).bind()
            eventInOrganisation(organisationId, eventId).bind()
            val cleaned = validate(organisationId, event).bind()
            events.update(eventId, cleaned).bind()
        }

    fun delete(organisationId: UUID, eventId: String, userId: UUID): SynciEither<Int> = either {
        access.requireAdmin(organisationId, userId).bind()
        eventInOrganisation(organisationId, eventId).bind()
        events.delete(eventId).bind()
    }

    private fun eventInOrganisation(organisationId: UUID, eventId: String): SynciEither<EventsTable> = either {
        val event = events.findById(eventId).bind()
        ensureNotNull(event) { ElementNotFound("Event $eventId nicht gefunden") }
        val sport = groups.findById(event.sportId).bind()
        ensure(sport?.organisationId == organisationId) { ElementNotFound("Event $eventId nicht gefunden") }
        event
    }

    private fun validate(organisationId: UUID, event: OrganisationEventDto): SynciEither<OrganisationEventDto> = either {
        val name = OrganisationService.validateName(event.name, "Eventname").bind()
        ensure(event.endsOn == null || !event.endsOn.isBefore(event.startsOn)) {
            InvalidRequest("Das Ende darf nicht vor dem Start liegen")
        }
        groups.requireInOrganisation(event.sportId, organisationId).bind()
        event.copy(
            name = name,
            description = event.description?.trim()?.ifEmpty { null },
            location = event.location?.trim()?.ifEmpty { null }
        )
    }
}
