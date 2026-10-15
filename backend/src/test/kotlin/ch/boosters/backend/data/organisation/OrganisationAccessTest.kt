package ch.boosters.backend.data.organisation

import ch.boosters.backend.errorhandling.Forbidden
import ch.boosters.backend.errorhandling.InvalidRequest
import ch.boosters.data.enums.OrgMemberStatus
import ch.boosters.data.enums.OrgRole
import ch.boosters.data.tables.pojos.OrganisationMembersTable
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import java.time.LocalDateTime
import java.util.UUID

class OrganisationAccessTest {

    private fun membership(role: OrgRole, status: OrgMemberStatus) = OrganisationMembersTable(
        UUID.randomUUID(), UUID.randomUUID(), UUID.randomUUID(), role, status, LocalDateTime.now()
    )

    @Test
    fun `no membership is forbidden`() {
        val result = OrganisationAccess.check(null, requireAdmin = false)
        assertTrue(result.leftOrNull() is Forbidden)
    }

    @Test
    fun `pending membership is forbidden`() {
        val result = OrganisationAccess.check(membership(OrgRole.MEMBER, OrgMemberStatus.PENDING), requireAdmin = false)
        assertTrue(result.leftOrNull() is Forbidden)
    }

    @Test
    fun `active member passes the member check but not the admin check`() {
        val member = membership(OrgRole.MEMBER, OrgMemberStatus.ACTIVE)
        assertEquals(member, OrganisationAccess.check(member, requireAdmin = false).getOrNull())
        assertTrue(OrganisationAccess.check(member, requireAdmin = true).leftOrNull() is Forbidden)
    }

    @Test
    fun `active admin passes both checks`() {
        val admin = membership(OrgRole.ADMIN, OrgMemberStatus.ACTIVE)
        assertEquals(admin, OrganisationAccess.check(admin, requireAdmin = false).getOrNull())
        assertEquals(admin, OrganisationAccess.check(admin, requireAdmin = true).getOrNull())
    }

    @Test
    fun `the last active admin cannot be removed`() {
        val admin = membership(OrgRole.ADMIN, OrgMemberStatus.ACTIVE)
        assertTrue(OrganisationAccess.ensureNotLastAdmin(admin, activeAdminCount = 1).leftOrNull() is InvalidRequest)
    }

    @Test
    fun `an admin can be removed when another admin remains`() {
        val admin = membership(OrgRole.ADMIN, OrgMemberStatus.ACTIVE)
        assertTrue(OrganisationAccess.ensureNotLastAdmin(admin, activeAdminCount = 2).isRight())
    }

    @Test
    fun `members and pending admins never block removal`() {
        assertTrue(OrganisationAccess.ensureNotLastAdmin(membership(OrgRole.MEMBER, OrgMemberStatus.ACTIVE), 1).isRight())
        assertTrue(OrganisationAccess.ensureNotLastAdmin(membership(OrgRole.ADMIN, OrgMemberStatus.PENDING), 1).isRight())
    }
}
