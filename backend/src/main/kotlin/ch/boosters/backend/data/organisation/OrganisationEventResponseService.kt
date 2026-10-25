package ch.boosters.backend.data.organisation

import arrow.core.raise.either
import arrow.core.raise.ensure
import arrow.core.raise.ensureNotNull
import ch.boosters.backend.data.organisation.model.EventInvitation
import ch.boosters.backend.data.organisation.model.EventResponseSummary
import ch.boosters.backend.data.organisation.model.MemberAnswer
import ch.boosters.backend.data.syncConfig.SyncConfigRepository
import ch.boosters.backend.errorhandling.ElementNotFound
import ch.boosters.backend.errorhandling.InvalidRequest
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.enums.EventAnswer
import ch.boosters.data.enums.OrgMemberStatus
import ch.boosters.data.enums.OrgRole
import ch.boosters.data.tables.pojos.EventsTable
import ch.boosters.data.tables.pojos.OrganisationEventResponsesTable
import ch.boosters.data.tables.pojos.OrganisationMembersTable
import org.springframework.stereotype.Service
import java.time.LocalDate
import java.util.UUID

/** Yes/no answers of members to organisation events that ask for them. */
@Service
class OrganisationEventResponseService(
    private val events: OrganisationEventRepository,
    private val responses: OrganisationEventResponseRepository,
    private val members: OrganisationMemberRepository,
    private val groups: OrganisationGroupRepository,
    private val organisations: OrganisationRepository,
    private val syncConfigs: SyncConfigRepository,
    private val access: OrganisationAccess
) {

    /** Events of the organisation from today on that ask for answers. */
    fun summaries(organisationId: UUID, userId: UUID): SynciEither<List<EventResponseSummary>> = either {
        val me = access.requireActiveMember(organisationId, userId).bind()
        val requested = events.withResponseRequested(organisationId, LocalDate.now().atStartOfDay()).bind()
        summarise(organisationId, requested, me).bind()
    }

    fun answer(organisationId: UUID, eventId: String, userId: UUID, answer: EventAnswer): SynciEither<EventResponseSummary> =
        either {
            val me = access.requireActiveMember(organisationId, userId).bind()
            val event = requestedEvent(eventId).bind()
            ensure(organisationOf(event).bind() == organisationId) { ElementNotFound("Event $eventId nicht gefunden") }
            responses.save(event.id, event.sourceId, userId, answer).bind()
            summarise(organisationId, listOf(event), me).bind().single()
        }

    /** The event behind the answer link in the calendar of [configId]; the link answers for the calendar's owner. */
    fun invitation(configId: UUID, eventId: String): SynciEither<EventInvitation> = either {
        val (event, organisationId, userId) = linked(configId, eventId).bind()
        val answer = responses.answers(event.sourceId, listOf(event.id)).bind().find { it.userId == userId }?.answer
        val organisation = organisations.findById(organisationId).bind()
        EventInvitation(event.id, event.name, event.startsOn, event.endsOn, event.location, organisation.name, answer)
    }

    fun answerViaLink(configId: UUID, eventId: String, answer: EventAnswer): SynciEither<EventInvitation> = either {
        val (event, _, userId) = linked(configId, eventId).bind()
        responses.save(event.id, event.sourceId, userId, answer).bind()
        invitation(configId, eventId).bind()
    }

    private fun linked(configId: UUID, eventId: String): SynciEither<Triple<EventsTable, UUID, UUID>> = either {
        val userId = syncConfigs.ownerOf(configId).bind()
        ensureNotNull(userId) { ElementNotFound("Dieser Link ist nicht mehr gültig") }
        val event = requestedEvent(eventId).bind()
        val organisationId = organisationOf(event).bind()
        access.requireActiveMember(organisationId, userId).bind()
        Triple(event, organisationId, userId)
    }

    private fun requestedEvent(eventId: String): SynciEither<EventsTable> = either {
        val event = events.findById(eventId).bind()
        ensureNotNull(event) { ElementNotFound("Event $eventId nicht gefunden") }
        ensure(event.responseRequested == true) { InvalidRequest("Für dieses Event werden keine Antworten gesammelt") }
        event
    }

    private fun organisationOf(event: EventsTable): SynciEither<UUID> = either {
        val organisationId = groups.findById(event.sportId).bind()?.organisationId
        ensureNotNull(organisationId) { ElementNotFound("Event ${event.id} nicht gefunden") }
    }

    private fun summarise(
        organisationId: UUID,
        events: List<EventsTable>,
        me: OrganisationMembersTable
    ): SynciEither<List<EventResponseSummary>> = either {
        if (events.isEmpty()) return@either emptyList()
        val active = members.listMembers(organisationId).bind().filter { it.membership.status == OrgMemberStatus.ACTIVE }
        val answers = responses.answers(events.first().sourceId, events.map { it.id }).bind().groupBy { it.eventId }
        events.map { summarise(it.id, active, answers[it.id].orEmpty(), me) }
    }

    companion object {
        /** Counts only active members, so answers of former members drop out without a cleanup. */
        fun summarise(
            eventId: String,
            active: List<MemberRecord>,
            answers: List<OrganisationEventResponsesTable>,
            me: OrganisationMembersTable
        ): EventResponseSummary {
            val activeIds = active.map { it.membership.userId }.toSet()
            val answerOf = answers.filter { it.userId in activeIds }.associate { it.userId to it.answer }
            return EventResponseSummary(
                eventId = eventId,
                yes = answerOf.values.count { it == EventAnswer.YES },
                no = answerOf.values.count { it == EventAnswer.NO },
                open = active.size - answerOf.size,
                myAnswer = answerOf[me.userId],
                members = if (me.role != OrgRole.ADMIN) null else active
                    .map { MemberAnswer(it.userName ?: it.userEmail, answerOf[it.membership.userId]) }
                    // yes first, then no, then open
                    .sortedWith(compareBy({ it.answer?.ordinal ?: EventAnswer.entries.size }, { it.name?.lowercase() }))
            )
        }
    }
}
