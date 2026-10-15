package ch.boosters.backend.data.organisation

import arrow.core.raise.either
import arrow.core.raise.ensureNotNull
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.errorhandling.DatabaseError
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.enums.OrgMemberStatus
import ch.boosters.data.enums.OrgRole
import ch.boosters.data.tables.pojos.OrganisationMembersTable
import ch.boosters.data.tables.references.ORGANISATION_MEMBERS_TABLE
import ch.boosters.data.tables.references.SYNC_CONFIGS_USERS_TABLE
import ch.boosters.data.tables.references.USERS_TABLE
import org.springframework.stereotype.Repository
import java.util.UUID

/** Membership row joined with the user's display data. */
data class MemberRecord(
    val membership: OrganisationMembersTable,
    val userName: String?,
    val userEmail: String?
)

@Repository
class OrganisationMemberRepository(private val dsl: JooqEitherDsl) {

    fun findMembership(organisationId: UUID, userId: UUID): SynciEither<OrganisationMembersTable?> =
        dsl {
            it.selectFrom(ORGANISATION_MEMBERS_TABLE)
                .where(ORGANISATION_MEMBERS_TABLE.ORGANISATION_ID.eq(organisationId))
                .and(ORGANISATION_MEMBERS_TABLE.USER_ID.eq(userId))
                .fetchOneInto(OrganisationMembersTable::class.java)
        }

    fun findById(memberId: UUID): SynciEither<OrganisationMembersTable?> =
        dsl {
            it.selectFrom(ORGANISATION_MEMBERS_TABLE)
                .where(ORGANISATION_MEMBERS_TABLE.ID.eq(memberId))
                .fetchOneInto(OrganisationMembersTable::class.java)
        }

    fun listMembers(organisationId: UUID): SynciEither<List<MemberRecord>> =
        dsl { ctx ->
            ctx.select(ORGANISATION_MEMBERS_TABLE.asterisk(), USERS_TABLE.NAME, USERS_TABLE.EMAIL)
                .from(ORGANISATION_MEMBERS_TABLE)
                .join(USERS_TABLE).on(USERS_TABLE.ID.eq(ORGANISATION_MEMBERS_TABLE.USER_ID))
                .where(ORGANISATION_MEMBERS_TABLE.ORGANISATION_ID.eq(organisationId))
                .orderBy(ORGANISATION_MEMBERS_TABLE.CREATED_AT)
                .fetch { record ->
                    MemberRecord(
                        membership = record.into(ORGANISATION_MEMBERS_TABLE).into(OrganisationMembersTable::class.java),
                        userName = record.get(USERS_TABLE.NAME),
                        userEmail = record.get(USERS_TABLE.EMAIL)
                    )
                }
        }

    fun insertPending(organisationId: UUID, userId: UUID): SynciEither<OrganisationMembersTable> = either {
        val created = dsl {
            it.insertInto(ORGANISATION_MEMBERS_TABLE)
                .columns(
                    ORGANISATION_MEMBERS_TABLE.ID,
                    ORGANISATION_MEMBERS_TABLE.ORGANISATION_ID,
                    ORGANISATION_MEMBERS_TABLE.USER_ID,
                    ORGANISATION_MEMBERS_TABLE.ROLE,
                    ORGANISATION_MEMBERS_TABLE.STATUS
                )
                .values(UUID.randomUUID(), organisationId, userId, OrgRole.MEMBER, OrgMemberStatus.PENDING)
                .returning()
                .fetchOne()
                ?.into(OrganisationMembersTable::class.java)
        }.bind()
        ensureNotNull(created) { DatabaseError("Beitrittsanfrage konnte nicht gespeichert werden") }
    }

    fun setStatus(memberId: UUID, status: OrgMemberStatus): SynciEither<Int> =
        dsl {
            it.update(ORGANISATION_MEMBERS_TABLE)
                .set(ORGANISATION_MEMBERS_TABLE.STATUS, status)
                .where(ORGANISATION_MEMBERS_TABLE.ID.eq(memberId))
                .execute()
        }

    fun setRole(memberId: UUID, role: OrgRole): SynciEither<Int> =
        dsl {
            it.update(ORGANISATION_MEMBERS_TABLE)
                .set(ORGANISATION_MEMBERS_TABLE.ROLE, role)
                .where(ORGANISATION_MEMBERS_TABLE.ID.eq(memberId))
                .execute()
        }

    fun delete(memberId: UUID): SynciEither<Int> =
        dsl {
            it.deleteFrom(ORGANISATION_MEMBERS_TABLE)
                .where(ORGANISATION_MEMBERS_TABLE.ID.eq(memberId))
                .execute()
        }

    fun countActiveAdmins(organisationId: UUID): SynciEither<Int> =
        dsl {
            it.fetchCount(
                ORGANISATION_MEMBERS_TABLE,
                ORGANISATION_MEMBERS_TABLE.ORGANISATION_ID.eq(organisationId)
                    .and(ORGANISATION_MEMBERS_TABLE.ROLE.eq(OrgRole.ADMIN))
                    .and(ORGANISATION_MEMBERS_TABLE.STATUS.eq(OrgMemberStatus.ACTIVE))
            )
        }

    /** Organisations the owner of a sync config is an active member of; used to filter the public calendar feed. */
    fun activeOrganisationIdsOfConfigOwner(syncConfigId: UUID): SynciEither<List<UUID>> =
        dsl { ctx ->
            ctx.selectDistinct(ORGANISATION_MEMBERS_TABLE.ORGANISATION_ID)
                .from(ORGANISATION_MEMBERS_TABLE)
                .join(SYNC_CONFIGS_USERS_TABLE)
                .on(SYNC_CONFIGS_USERS_TABLE.USER_ID.eq(ORGANISATION_MEMBERS_TABLE.USER_ID))
                .where(SYNC_CONFIGS_USERS_TABLE.SYNC_CONFIG_ID.eq(syncConfigId))
                .and(ORGANISATION_MEMBERS_TABLE.STATUS.eq(OrgMemberStatus.ACTIVE))
                .fetch(ORGANISATION_MEMBERS_TABLE.ORGANISATION_ID)
                .filterNotNull()
        }
}
