package ch.boosters.backend.data.organisation.model

import ch.boosters.backend.data.sport.model.Sport
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
    val sportId: UUID
)

data class RoleUpdateDto(val role: OrgRole)

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
