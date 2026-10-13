package ch.boosters.backend.data.organisation

import arrow.core.raise.either
import arrow.core.raise.ensureNotNull
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.data.organisation.model.OrganisationDto
import ch.boosters.backend.data.organisation.model.OrganisationSummary
import ch.boosters.backend.errorhandling.ElementNotFound
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.enums.OrgMemberStatus
import ch.boosters.data.enums.OrgRole
import ch.boosters.data.tables.pojos.OrganisationMembersTable
import ch.boosters.data.tables.pojos.OrganisationsTable
import ch.boosters.data.tables.pojos.SportsTable
import ch.boosters.data.tables.references.ORGANISATIONS_TABLE
import ch.boosters.data.tables.references.ORGANISATION_MEMBERS_TABLE
import ch.boosters.data.tables.references.SPORTS_TABLE
import org.jooq.Condition
import org.jooq.impl.DSL
import org.springframework.stereotype.Repository
import java.util.UUID

data class OrganisationWithMembership(
    val organisation: OrganisationsTable,
    val membership: OrganisationMembersTable
)

/** Technical sport keys; sports_table.name is unique, the display name lives in label. */
fun organisationSportName(organisationId: UUID) = "ORG_$organisationId"
fun groupSportName(groupId: UUID) = "GRP_$groupId"

@Repository
class OrganisationRepository(private val dsl: JooqEitherDsl) {

    /** Creates the organisation, its root node in the sport tree and the creator's admin membership in one transaction. */
    fun create(organisation: OrganisationDto, creatorId: UUID): SynciEither<UUID> = either {
        val organisationId = UUID.randomUUID()
        dsl { ctx ->
            ctx.transaction { config ->
                val tx = DSL.using(config)
                tx.insertInto(ORGANISATIONS_TABLE)
                    .columns(
                        ORGANISATIONS_TABLE.ID,
                        ORGANISATIONS_TABLE.NAME,
                        ORGANISATIONS_TABLE.DESCRIPTION,
                        ORGANISATIONS_TABLE.CREATED_BY
                    )
                    .values(organisationId, organisation.name, organisation.description, creatorId)
                    .execute()

                tx.insertInto(SPORTS_TABLE)
                    .columns(SPORTS_TABLE.ID, SPORTS_TABLE.NAME, SPORTS_TABLE.LABEL, SPORTS_TABLE.ORGANISATION_ID)
                    .values(UUID.randomUUID(), organisationSportName(organisationId), organisation.name, organisationId)
                    .execute()

                tx.insertInto(ORGANISATION_MEMBERS_TABLE)
                    .columns(
                        ORGANISATION_MEMBERS_TABLE.ID,
                        ORGANISATION_MEMBERS_TABLE.ORGANISATION_ID,
                        ORGANISATION_MEMBERS_TABLE.USER_ID,
                        ORGANISATION_MEMBERS_TABLE.ROLE,
                        ORGANISATION_MEMBERS_TABLE.STATUS
                    )
                    .values(UUID.randomUUID(), organisationId, creatorId, OrgRole.ADMIN, OrgMemberStatus.ACTIVE)
                    .execute()
            }
        }.bind()
        organisationId
    }

    fun findById(id: UUID): SynciEither<OrganisationsTable> = either {
        val organisation = dsl {
            it.selectFrom(ORGANISATIONS_TABLE)
                .where(ORGANISATIONS_TABLE.ID.eq(id))
                .fetchOneInto(OrganisationsTable::class.java)
        }.bind()
        ensureNotNull(organisation) { ElementNotFound("Organisation $id nicht gefunden") }
    }

    /** The organisation's root node in the sport tree. */
    fun rootSport(organisationId: UUID): SynciEither<SportsTable> = either {
        val root = dsl {
            it.selectFrom(SPORTS_TABLE)
                .where(SPORTS_TABLE.ORGANISATION_ID.eq(organisationId))
                .and(SPORTS_TABLE.PARENT_ID.isNull)
                .fetchOneInto(SportsTable::class.java)
        }.bind()
        ensureNotNull(root) { ElementNotFound("Organisation $organisationId hat keinen Eintrag im Sport-Tree") }
    }

    /** Updates name/description and keeps the root node's label in sync. */
    fun update(id: UUID, organisation: OrganisationDto): SynciEither<Int> =
        dsl { ctx ->
            ctx.transaction { config ->
                val tx = DSL.using(config)
                tx.update(ORGANISATIONS_TABLE)
                    .set(ORGANISATIONS_TABLE.NAME, organisation.name)
                    .set(ORGANISATIONS_TABLE.DESCRIPTION, organisation.description)
                    .where(ORGANISATIONS_TABLE.ID.eq(id))
                    .execute()
                tx.update(SPORTS_TABLE)
                    .set(SPORTS_TABLE.LABEL, organisation.name)
                    .where(SPORTS_TABLE.ORGANISATION_ID.eq(id))
                    .and(SPORTS_TABLE.PARENT_ID.isNull)
                    .execute()
            }
            1
        }

    /** Sports and memberships are removed by FK cascade; events must be deleted by the caller first. */
    fun delete(id: UUID): SynciEither<Int> =
        dsl {
            it.deleteFrom(ORGANISATIONS_TABLE)
                .where(ORGANISATIONS_TABLE.ID.eq(id))
                .execute()
        }

    /** All organisations the user has a membership row for, active or pending. */
    fun findByUser(userId: UUID): SynciEither<List<OrganisationWithMembership>> =
        dsl { ctx ->
            ctx.select(ORGANISATIONS_TABLE.asterisk(), ORGANISATION_MEMBERS_TABLE.asterisk())
                .from(ORGANISATIONS_TABLE)
                .join(ORGANISATION_MEMBERS_TABLE)
                .on(ORGANISATION_MEMBERS_TABLE.ORGANISATION_ID.eq(ORGANISATIONS_TABLE.ID))
                .where(ORGANISATION_MEMBERS_TABLE.USER_ID.eq(userId))
                .orderBy(ORGANISATIONS_TABLE.NAME)
                .fetch { record ->
                    OrganisationWithMembership(
                        record.into(ORGANISATIONS_TABLE).into(OrganisationsTable::class.java),
                        record.into(ORGANISATION_MEMBERS_TABLE).into(OrganisationMembersTable::class.java)
                    )
                }
        }

    /** Public listing with the caller's own membership state, if any. */
    fun discover(userId: UUID, searchTerm: String?, limit: Int, offset: Int): SynciEither<List<OrganisationSummary>> =
        dsl { ctx ->
            val me = ORGANISATION_MEMBERS_TABLE.`as`("me")
            val memberCount = DSL.selectCount()
                .from(ORGANISATION_MEMBERS_TABLE)
                .where(ORGANISATION_MEMBERS_TABLE.ORGANISATION_ID.eq(ORGANISATIONS_TABLE.ID))
                .and(ORGANISATION_MEMBERS_TABLE.STATUS.eq(OrgMemberStatus.ACTIVE))
                .asField<Int>("member_count")

            ctx.select(
                ORGANISATIONS_TABLE.ID,
                ORGANISATIONS_TABLE.NAME,
                ORGANISATIONS_TABLE.DESCRIPTION,
                memberCount,
                me.STATUS,
                me.ROLE
            )
                .from(ORGANISATIONS_TABLE)
                .leftJoin(me)
                .on(me.ORGANISATION_ID.eq(ORGANISATIONS_TABLE.ID).and(me.USER_ID.eq(userId)))
                .where(searchCondition(searchTerm))
                .orderBy(ORGANISATIONS_TABLE.NAME)
                .limit(offset, limit)
                .fetch { record ->
                    OrganisationSummary(
                        id = record.get(ORGANISATIONS_TABLE.ID)!!,
                        name = record.get(ORGANISATIONS_TABLE.NAME)!!,
                        description = record.get(ORGANISATIONS_TABLE.DESCRIPTION),
                        memberCount = record.get(memberCount) ?: 0,
                        membershipStatus = record.get(me.STATUS),
                        role = record.get(me.ROLE)
                    )
                }
        }

    fun discoverCount(searchTerm: String?): SynciEither<Int> =
        dsl { it.fetchCount(ORGANISATIONS_TABLE, searchCondition(searchTerm)) }

    private fun searchCondition(searchTerm: String?): Condition =
        if (searchTerm.isNullOrBlank()) DSL.noCondition()
        else ORGANISATIONS_TABLE.NAME.containsIgnoreCase(searchTerm.trim())
}
