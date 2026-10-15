package ch.boosters.backend.data.organisation

import arrow.core.flatMap
import arrow.core.raise.either
import arrow.core.raise.ensure
import arrow.core.raise.ensureNotNull
import ch.boosters.backend.errorhandling.Forbidden
import ch.boosters.backend.errorhandling.InvalidRequest
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.enums.OrgMemberStatus
import ch.boosters.data.enums.OrgRole
import ch.boosters.data.tables.pojos.OrganisationMembersTable
import org.springframework.stereotype.Component
import java.util.UUID

/**
 * Authorisation rules for organisations. Non-members and pending members are treated the same (403),
 * so an outsider cannot tell whether an organisation exists.
 */
@Component
class OrganisationAccess(private val members: OrganisationMemberRepository) {

    fun requireActiveMember(organisationId: UUID, userId: UUID): SynciEither<OrganisationMembersTable> =
        members.findMembership(organisationId, userId).flatMap { check(it, requireAdmin = false) }

    fun requireAdmin(organisationId: UUID, userId: UUID): SynciEither<OrganisationMembersTable> =
        members.findMembership(organisationId, userId).flatMap { check(it, requireAdmin = true) }

    companion object {
        fun check(membership: OrganisationMembersTable?, requireAdmin: Boolean): SynciEither<OrganisationMembersTable> =
            either {
                ensureNotNull(membership) { Forbidden("Kein aktives Mitglied dieses Vereins") }
                ensure(membership.status == OrgMemberStatus.ACTIVE) { Forbidden("Kein aktives Mitglied dieses Vereins") }
                ensure(!requireAdmin || membership.role == OrgRole.ADMIN) {
                    Forbidden("Nur Admins dürfen diese Aktion ausführen")
                }
                membership
            }

        /** An organisation must always keep at least one active admin. */
        fun ensureNotLastAdmin(target: OrganisationMembersTable, activeAdminCount: Int): SynciEither<Unit> = either {
            val isActiveAdmin = target.role == OrgRole.ADMIN && target.status == OrgMemberStatus.ACTIVE
            ensure(!(isActiveAdmin && activeAdminCount <= 1)) {
                InvalidRequest("Der letzte Admin kann den Verein nicht verlassen oder herabgestuft werden")
            }
        }
    }
}
