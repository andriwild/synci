package ch.boosters.backend.data.organisation

import arrow.core.raise.either
import arrow.core.raise.ensure
import arrow.core.raise.ensureNotNull
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.errorhandling.DatabaseError
import ch.boosters.backend.errorhandling.ElementNotFound
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.tables.pojos.SportsTable
import ch.boosters.data.tables.references.SPORTS_TABLE
import org.springframework.stereotype.Repository
import java.util.UUID

/** Groups of an organisation are child rows of its root node in sports_table. */
@Repository
class OrganisationGroupRepository(private val dsl: JooqEitherDsl) {

    fun findById(groupId: UUID): SynciEither<SportsTable?> =
        dsl {
            it.selectFrom(SPORTS_TABLE)
                .where(SPORTS_TABLE.ID.eq(groupId))
                .fetchOneInto(SportsTable::class.java)
        }

    fun create(organisationId: UUID, rootSportId: UUID, label: String): SynciEither<SportsTable> = either {
        val groupId = UUID.randomUUID()
        val created = dsl {
            it.insertInto(SPORTS_TABLE)
                .columns(SPORTS_TABLE.ID, SPORTS_TABLE.NAME, SPORTS_TABLE.LABEL, SPORTS_TABLE.PARENT_ID, SPORTS_TABLE.ORGANISATION_ID)
                .values(groupId, groupSportName(groupId), label, rootSportId, organisationId)
                .returning()
                .fetchOne()
                ?.into(SportsTable::class.java)
        }.bind()
        ensureNotNull(created) { DatabaseError("Gruppe konnte nicht erstellt werden") }
    }

    fun rename(groupId: UUID, label: String): SynciEither<SportsTable> = either {
        val updated = dsl {
            it.update(SPORTS_TABLE)
                .set(SPORTS_TABLE.LABEL, label)
                .where(SPORTS_TABLE.ID.eq(groupId))
                .returning()
                .fetchOne()
                ?.into(SportsTable::class.java)
        }.bind()
        ensureNotNull(updated) { DatabaseError("Gruppe $groupId konnte nicht umbenannt werden") }
    }

    /** Subscriptions in sync_configs_sports_table are removed by FK cascade. */
    fun delete(groupId: UUID): SynciEither<Int> =
        dsl {
            it.deleteFrom(SPORTS_TABLE)
                .where(SPORTS_TABLE.ID.eq(groupId))
                .execute()
        }

    /** The root node or one of the groups of the organisation; 404 otherwise. */
    fun requireInOrganisation(sportId: UUID, organisationId: UUID): SynciEither<SportsTable> = either {
        val sport = findById(sportId).bind()
        ensureNotNull(sport) { ElementNotFound("Gruppe $sportId nicht gefunden") }
        ensure(sport.organisationId == organisationId) { ElementNotFound("Gruppe $sportId nicht gefunden") }
        sport
    }

    /** Like [requireInOrganisation] but rejects the root node, which cannot be renamed or deleted as a group. */
    fun requireGroupInOrganisation(groupId: UUID, organisationId: UUID): SynciEither<SportsTable> = either {
        val sport = requireInOrganisation(groupId, organisationId).bind()
        ensure(sport.parentId != null) { ElementNotFound("Gruppe $groupId nicht gefunden") }
        sport
    }

    fun existsByLabel(organisationId: UUID, label: String, excludeGroupId: UUID? = null): SynciEither<Boolean> =
        dsl {
            var condition = SPORTS_TABLE.ORGANISATION_ID.eq(organisationId)
                .and(SPORTS_TABLE.PARENT_ID.isNotNull)
                .and(SPORTS_TABLE.LABEL.equalIgnoreCase(label))
            if (excludeGroupId != null) {
                condition = condition.and(SPORTS_TABLE.ID.ne(excludeGroupId))
            }
            it.fetchExists(it.selectOne().from(SPORTS_TABLE).where(condition))
        }
}
