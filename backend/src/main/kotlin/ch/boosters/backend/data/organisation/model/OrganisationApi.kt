package ch.boosters.backend.data.organisation.model

import ch.boosters.backend.data.sport.model.Sport
import ch.boosters.data.enums.EventAnswer
import ch.boosters.data.enums.OrgMemberStatus
import ch.boosters.data.enums.OrgRole
import java.time.LocalDateTime
import java.util.UUID

// ---- request bodies ----

data class OrganisationDto(val name: String, val description: String?)

data class GroupDto(val name: String)

data class OrganisationEventDto(
    val name: String,
    val description: String?,
    val location: String?,
    val startsOn: LocalDateTime,
    /** null = all-day event */
    val endsOn: LocalDateTime?,
    /** the organisation's root sport or one of its groups */
    val sportId: UUID,
    /** members are asked to answer yes or no */
    val responseRequested: Boolean = false
)

data class RoleUpdateDto(val role: OrgRole)

data class AnswerDto(val answer: EventAnswer)

// ---- responses ----

/** An organisation the current user belongs to (active or pending), with its sport subtree (root + groups). */
data class MyOrganisation(
    val id: UUID,
    val name: String,
    val description: String?,
    val role: OrgRole,
    val status: OrgMemberStatus,
    val sport: Sport
)

/** Public view used by "Organisationen entdecken": only the caller's own membership state. */
data class OrganisationSummary(
    val id: UUID,
    val name: String,
    val description: String?,
    val memberCount: Int,
    val membershipStatus: OrgMemberStatus?,
    val role: OrgRole?
)

/** Detail view for active members. */
data class OrganisationView(
    val id: UUID,
    val name: String,
    val description: String?,
    val role: OrgRole,
    val sport: Sport
)

data class MemberView(
    val id: UUID,
    val userId: UUID,
    val name: String?,
    val email: String?,
    val role: OrgRole,
    val status: OrgMemberStatus,
    val createdAt: LocalDateTime?,
    /** true for the row of the requesting user; computed server-side because the frontend does not know its user UUID */
    val isMe: Boolean
)

/** Answers of the active members to an event that asks for them. */
data class EventResponseSummary(
    val eventId: String,
    val yes: Int,
    val no: Int,
    /** active members without an answer */
    val open: Int,
    val myAnswer: EventAnswer?,
    /** every active member with their answer; only for admins */
    val members: List<MemberAnswer>?
)

data class MemberAnswer(val name: String?, val answer: EventAnswer?)

/** What the answer link in the calendar shows: the event and the answer of the calendar's owner. */
data class EventInvitation(
    val eventId: String,
    val name: String,
    val startsOn: LocalDateTime,
    /** null = all-day event */
    val endsOn: LocalDateTime?,
    val location: String?,
    val organisation: String,
    val answer: EventAnswer?
)
