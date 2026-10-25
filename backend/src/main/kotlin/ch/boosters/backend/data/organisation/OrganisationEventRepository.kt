package ch.boosters.backend.data.organisation

import arrow.core.raise.either
import arrow.core.raise.ensureNotNull
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.data.organisation.model.OrganisationEventDto
import ch.boosters.backend.errorhandling.DatabaseError
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.tables.pojos.EventsTable
import ch.boosters.data.tables.references.EVENTS_TABLE
import ch.boosters.data.tables.references.SOURCES_TABLE
import ch.boosters.data.tables.references.SPORTS_TABLE
import org.jooq.impl.DSL
import org.springframework.stereotype.Repository
import java.time.LocalDateTime
import java.util.UUID

const val ORGANISATION_SOURCE_NAME = "ORGANISATION"

/** Organisation events are regular rows in events_table under the source "ORGANISATION". */
@Repository
class OrganisationEventRepository(private val dsl: JooqEitherDsl) {

    @Volatile
    private var cachedSourceId: Int? = null

    fun sourceId(): SynciEither<Int> = either {
        cachedSourceId?.let { return@either it }
        val id = dsl {
            it.select(SOURCES_TABLE.ID)
                .from(SOURCES_TABLE)
                .where(SOURCES_TABLE.NAME.eq(ORGANISATION_SOURCE_NAME))
                .fetchOne(SOURCES_TABLE.ID)
        }.bind()
        ensureNotNull(id) { DatabaseError("Quelle $ORGANISATION_SOURCE_NAME fehlt in sources_table") }
        cachedSourceId = id
        id
    }

    fun findById(eventId: String): SynciEither<EventsTable?> = either {
        val sourceId = sourceId().bind()
        dsl {
            it.selectFrom(EVENTS_TABLE)
                .where(EVENTS_TABLE.ID.eq(eventId))
                .and(EVENTS_TABLE.SOURCE_ID.eq(sourceId))
                .fetchOneInto(EventsTable::class.java)
        }.bind()
    }

    fun create(event: OrganisationEventDto): SynciEither<EventsTable> = either {
        val sourceId = sourceId().bind()
        val created = dsl {
            it.insertInto(EVENTS_TABLE)
                .columns(
                    EVENTS_TABLE.ID,
                    EVENTS_TABLE.SOURCE_ID,
                    EVENTS_TABLE.NAME,
                    EVENTS_TABLE.STARTS_ON,
                    EVENTS_TABLE.ENDS_ON,
                    EVENTS_TABLE.SPORT_ID,
                    EVENTS_TABLE.LOCATION,
                    EVENTS_TABLE.DESCRIPTION,
                    EVENTS_TABLE.RESPONSE_REQUESTED
                )
                .values(
                    UUID.randomUUID().toString(),
                    sourceId,
                    event.name,
                    event.startsOn,
                    event.endsOn,
                    event.sportId,
                    event.location,
                    event.description,
                    event.responseRequested
                )
                .returning()
                .fetchOne()
                ?.into(EventsTable::class.java)
        }.bind()
        ensureNotNull(created) { DatabaseError("Event konnte nicht erstellt werden") }
    }

    fun update(eventId: String, event: OrganisationEventDto): SynciEither<EventsTable> = either {
        val sourceId = sourceId().bind()
        val updated = dsl {
            it.update(EVENTS_TABLE)
                .set(EVENTS_TABLE.NAME, event.name)
                .set(EVENTS_TABLE.STARTS_ON, event.startsOn)
                .set(EVENTS_TABLE.ENDS_ON, event.endsOn)
                .set(EVENTS_TABLE.SPORT_ID, event.sportId)
                .set(EVENTS_TABLE.LOCATION, event.location)
                .set(EVENTS_TABLE.DESCRIPTION, event.description)
                .set(EVENTS_TABLE.RESPONSE_REQUESTED, event.responseRequested)
                .where(EVENTS_TABLE.ID.eq(eventId))
                .and(EVENTS_TABLE.SOURCE_ID.eq(sourceId))
                .returning()
                .fetchOne()
                ?.into(EventsTable::class.java)
        }.bind()
        ensureNotNull(updated) { DatabaseError("Event $eventId konnte nicht aktualisiert werden") }
    }

    fun delete(eventId: String): SynciEither<Int> = either {
        val sourceId = sourceId().bind()
        dsl {
            it.deleteFrom(EVENTS_TABLE)
                .where(EVENTS_TABLE.ID.eq(eventId))
                .and(EVENTS_TABLE.SOURCE_ID.eq(sourceId))
                .execute()
        }.bind()
    }

    /** Events of the organisation that ask for answers and have not ended before [from], earliest first. */
    fun withResponseRequested(organisationId: UUID, from: LocalDateTime): SynciEither<List<EventsTable>> = either {
        val sourceId = sourceId().bind()
        dsl {
            it.select(EVENTS_TABLE.asterisk())
                .from(EVENTS_TABLE)
                .join(SPORTS_TABLE).on(SPORTS_TABLE.ID.eq(EVENTS_TABLE.SPORT_ID))
                .where(SPORTS_TABLE.ORGANISATION_ID.eq(organisationId))
                .and(EVENTS_TABLE.SOURCE_ID.eq(sourceId))
                .and(EVENTS_TABLE.RESPONSE_REQUESTED.isTrue)
                .and(DSL.coalesce(EVENTS_TABLE.ENDS_ON, EVENTS_TABLE.STARTS_ON).ge(from))
                .orderBy(EVENTS_TABLE.STARTS_ON)
                .fetchInto(EventsTable::class.java)
        }.bind()
    }

    /** Used when a group is deleted: its events become organisation-wide events. */
    fun moveEvents(fromSportId: UUID, toSportId: UUID): SynciEither<Int> =
        dsl {
            it.update(EVENTS_TABLE)
                .set(EVENTS_TABLE.SPORT_ID, toSportId)
                .where(EVENTS_TABLE.SPORT_ID.eq(fromSportId))
                .execute()
        }

    /** Used before an organisation is deleted, because events_table.sport_id is NOT NULL. */
    fun deleteEventsOfSports(sportIds: Collection<UUID>): SynciEither<Int> =
        if (sportIds.isEmpty()) either { 0 }
        else dsl {
            it.deleteFrom(EVENTS_TABLE)
                .where(EVENTS_TABLE.SPORT_ID.`in`(sportIds))
                .execute()
        }
}
