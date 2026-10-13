package ch.boosters.backend.data.organisation

import arrow.core.raise.either
import arrow.core.raise.ensure
import arrow.core.raise.ensureNotNull
import ch.boosters.backend.data.organisation.model.GroupDto
import ch.boosters.backend.data.organisation.model.MemberView
import ch.boosters.backend.data.organisation.model.MyOrganisation
import ch.boosters.backend.data.organisation.model.OrganisationDto
import ch.boosters.backend.data.organisation.model.OrganisationSummary
import ch.boosters.backend.data.organisation.model.OrganisationView
import ch.boosters.backend.data.organisation.model.RoleUpdateDto
import ch.boosters.backend.data.sport.SportsRepository
import ch.boosters.backend.data.sport.business.findSportsByParent
import ch.boosters.backend.data.sport.model.PagedResult
import ch.boosters.backend.data.sport.model.Sport
import ch.boosters.backend.data.sport.model.toSport
import ch.boosters.backend.errorhandling.ElementNotFound
import ch.boosters.backend.errorhandling.InvalidRequest
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.enums.OrgMemberStatus
import ch.boosters.data.enums.OrgRole
import ch.boosters.data.tables.pojos.OrganisationMembersTable
import ch.boosters.data.tables.pojos.SportsTable
import org.springframework.stereotype.Service
import java.util.UUID

const val MAX_NAME_LENGTH = 100

@Service
class OrganisationService(
    private val organisations: OrganisationRepository,
    private val groups: OrganisationGroupRepository,
    private val members: OrganisationMemberRepository,
    private val events: OrganisationEventRepository,
    private val sports: SportsRepository,
    private val access: OrganisationAccess
) {

    // ---- organisations ----

    fun create(organisation: OrganisationDto, userId: UUID): SynciEither<OrganisationView> = either {
        val cleaned = validateOrganisation(organisation).bind()
        val id = organisations.create(cleaned, userId).bind()
        getById(id, userId).bind()
    }

    /** Own organisations with their sport subtree: active ones first, admins before members, then by name. */
    fun myOrganisations(userId: UUID): SynciEither<List<MyOrganisation>> = either {
        val rows = organisations.findByUser(userId).bind()
        val organisationSports = sports.sportsOfOrganisations(rows.map { it.organisation.id }).bind()
        rows.map { row ->
            MyOrganisation(
                id = row.organisation.id,
                name = row.organisation.name,
                description = row.organisation.description,
                role = row.membership.role ?: OrgRole.MEMBER,
                status = row.membership.status ?: OrgMemberStatus.PENDING,
                sport = organisationTree(row.organisation.id, organisationSports).bind()
            )
        }.sortedWith(
            compareBy<MyOrganisation>({ it.status != OrgMemberStatus.ACTIVE }, { it.role != OrgRole.ADMIN })
                .thenBy { it.name.lowercase() }
        )
    }

    fun discover(userId: UUID, searchTerm: String?, page: Int, pageSize: Int): SynciEither<PagedResult<OrganisationSummary>> =
        either {
            val amount = organisations.discoverCount(searchTerm).bind()
            val elements = organisations.discover(userId, searchTerm, pageSize, page * pageSize).bind()
            PagedResult(amount, page, pageSize, elements)
        }

    fun getById(organisationId: UUID, userId: UUID): SynciEither<OrganisationView> = either {
        val membership = access.requireActiveMember(organisationId, userId).bind()
        val organisation = organisations.findById(organisationId).bind()
        val organisationSports = sports.sportsOfOrganisations(listOf(organisationId)).bind()
        OrganisationView(
            id = organisation.id,
            name = organisation.name,
            description = organisation.description,
            role = membership.role ?: OrgRole.MEMBER,
            sport = organisationTree(organisationId, organisationSports).bind()
        )
    }

    fun update(organisationId: UUID, organisation: OrganisationDto, userId: UUID): SynciEither<OrganisationView> = either {
        access.requireAdmin(organisationId, userId).bind()
        val cleaned = validateOrganisation(organisation).bind()
        organisations.update(organisationId, cleaned).bind()
        getById(organisationId, userId).bind()
    }

    /** Events are removed first (sport_id is NOT NULL); sports and memberships follow by FK cascade. */
    fun delete(organisationId: UUID, userId: UUID): SynciEither<Int> = either {
        access.requireAdmin(organisationId, userId).bind()
        val organisationSports = sports.sportsOfOrganisations(listOf(organisationId)).bind()
        events.deleteEventsOfSports(organisationSports.map { it.id }).bind()
        organisations.delete(organisationId).bind()
    }

    // ---- membership ----

    /** Creates a pending membership. Calling it again while pending is a no-op. */
    fun requestJoin(organisationId: UUID, userId: UUID): SynciEither<OrganisationMembersTable> = either {
        organisations.findById(organisationId).bind()
        val existing = members.findMembership(organisationId, userId).bind()
        when {
            existing == null -> members.insertPending(organisationId, userId).bind()
            existing.status == OrgMemberStatus.ACTIVE -> raise(InvalidRequest("Du bist bereits Mitglied dieser Organisation"))
            else -> existing
        }
    }

    /** Leaves the organisation or withdraws a pending request. */
    fun leave(organisationId: UUID, userId: UUID): SynciEither<Int> = either {
        val membership = members.findMembership(organisationId, userId).bind()
        ensureNotNull(membership) { ElementNotFound("Keine Mitgliedschaft in Organisation $organisationId") }
        val adminCount = members.countActiveAdmins(organisationId).bind()
        OrganisationAccess.ensureNotLastAdmin(membership, adminCount).bind()
        members.delete(membership.id).bind()
    }

    /** Admins see pending requests as well, members only see active members. */
    fun members(organisationId: UUID, userId: UUID): SynciEither<List<MemberView>> = either {
        val me = access.requireActiveMember(organisationId, userId).bind()
        members.listMembers(organisationId).bind()
            .filter { me.role == OrgRole.ADMIN || it.membership.status == OrgMemberStatus.ACTIVE }
            .map { toMemberView(it, userId) }
    }

    fun approve(organisationId: UUID, memberId: UUID, userId: UUID): SynciEither<MemberView> = either {
        access.requireAdmin(organisationId, userId).bind()
        val target = memberInOrganisation(organisationId, memberId).bind()
        members.setStatus(target.id, OrgMemberStatus.ACTIVE).bind()
        memberView(organisationId, memberId, userId).bind()
    }

    /** Rejects a pending request or removes an active member. */
    fun removeMember(organisationId: UUID, memberId: UUID, userId: UUID): SynciEither<Int> = either {
        access.requireAdmin(organisationId, userId).bind()
        val target = memberInOrganisation(organisationId, memberId).bind()
        val adminCount = members.countActiveAdmins(organisationId).bind()
        OrganisationAccess.ensureNotLastAdmin(target, adminCount).bind()
        members.delete(target.id).bind()
    }

    fun changeRole(organisationId: UUID, memberId: UUID, update: RoleUpdateDto, userId: UUID): SynciEither<MemberView> =
        either {
            access.requireAdmin(organisationId, userId).bind()
            val target = memberInOrganisation(organisationId, memberId).bind()
            ensure(target.status == OrgMemberStatus.ACTIVE) {
                InvalidRequest("Die Rolle kann erst nach der Freigabe geändert werden")
            }
            if (update.role != OrgRole.ADMIN) {
                val adminCount = members.countActiveAdmins(organisationId).bind()
                OrganisationAccess.ensureNotLastAdmin(target, adminCount).bind()
            }
            members.setRole(target.id, update.role).bind()
            memberView(organisationId, memberId, userId).bind()
        }

    // ---- groups (child nodes of the organisation's root sport) ----

    fun createGroup(organisationId: UUID, group: GroupDto, userId: UUID): SynciEither<Sport> = either {
        access.requireAdmin(organisationId, userId).bind()
        val label = validateName(group.name, "Gruppenname").bind()
        ensure(!groups.existsByLabel(organisationId, label).bind()) {
            InvalidRequest("Eine Gruppe mit diesem Namen existiert bereits")
        }
        val root = organisations.rootSport(organisationId).bind()
        groups.create(organisationId, root.id, label).bind().toSport()
    }

    fun updateGroup(organisationId: UUID, groupId: UUID, group: GroupDto, userId: UUID): SynciEither<Sport> = either {
        access.requireAdmin(organisationId, userId).bind()
        groups.requireGroupInOrganisation(groupId, organisationId).bind()
        val label = validateName(group.name, "Gruppenname").bind()
        ensure(!groups.existsByLabel(organisationId, label, excludeGroupId = groupId).bind()) {
            InvalidRequest("Eine Gruppe mit diesem Namen existiert bereits")
        }
        groups.rename(groupId, label).bind().toSport()
    }

    /** Events of the group move to the organisation root, group subscriptions are dropped by FK cascade. */
    fun deleteGroup(organisationId: UUID, groupId: UUID, userId: UUID): SynciEither<Int> = either {
        access.requireAdmin(organisationId, userId).bind()
        groups.requireGroupInOrganisation(groupId, organisationId).bind()
        val root = organisations.rootSport(organisationId).bind()
        events.moveEvents(groupId, root.id).bind()
        groups.delete(groupId).bind()
    }

    // ---- helpers ----

    private fun organisationTree(organisationId: UUID, organisationSports: List<SportsTable>): SynciEither<Sport> = either {
        val root = organisationSports.find { it.organisationId == organisationId && it.parentId == null }
        ensureNotNull(root) { ElementNotFound("Organisation $organisationId hat keinen Eintrag im Sport-Tree") }
        val tree = organisationSports.findSportsByParent(root.id)
        ensureNotNull(tree) { ElementNotFound("Organisation $organisationId hat keinen Eintrag im Sport-Tree") }
        tree
    }

    private fun memberInOrganisation(organisationId: UUID, memberId: UUID): SynciEither<OrganisationMembersTable> = either {
        val membership = members.findById(memberId).bind()
        ensureNotNull(membership) { ElementNotFound("Mitglied $memberId nicht gefunden") }
        ensure(membership.organisationId == organisationId) { ElementNotFound("Mitglied $memberId nicht gefunden") }
        membership
    }

    private fun memberView(organisationId: UUID, memberId: UUID, userId: UUID): SynciEither<MemberView> = either {
        val row = members.listMembers(organisationId).bind().find { it.membership.id == memberId }
        ensureNotNull(row) { ElementNotFound("Mitglied $memberId nicht gefunden") }
        toMemberView(row, userId)
    }

    private fun toMemberView(row: MemberRecord, userId: UUID) = MemberView(
        id = row.membership.id,
        userId = row.membership.userId,
        name = row.userName,
        email = row.userEmail,
        role = row.membership.role ?: OrgRole.MEMBER,
        status = row.membership.status ?: OrgMemberStatus.PENDING,
        createdAt = row.membership.createdAt,
        isMe = row.membership.userId == userId
    )

    private fun validateOrganisation(organisation: OrganisationDto): SynciEither<OrganisationDto> = either {
        val name = validateName(organisation.name, "Name der Organisation").bind()
        OrganisationDto(name, organisation.description?.trim()?.ifEmpty { null })
    }

    companion object {
        fun validateName(raw: String, label: String): SynciEither<String> = either {
            val name = raw.trim()
            ensure(name.isNotEmpty()) { InvalidRequest("$label darf nicht leer sein") }
            ensure(name.length <= MAX_NAME_LENGTH) { InvalidRequest("$label darf höchstens $MAX_NAME_LENGTH Zeichen lang sein") }
            name
        }
    }
}
