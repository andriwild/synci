package ch.boosters.backend.data.syncConfig.syncConfigEvents

import arrow.core.raise.either
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.data.syncConfig.model.EventDto
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.Tables.EVENTS_TABLE
import ch.boosters.data.Tables.SYNC_CONFIGS_EVENTS_TABLE
import ch.boosters.data.tables.pojos.EventsTable
import org.jooq.DSLContext
import org.jooq.impl.DSL
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class SyncConfigEventsRepository(private val dsl: JooqEitherDsl) {

    fun updateEvents(configId: UUID, events: List<EventDto>): SynciEither<List<EventDto>> = either {
        dsl {
            it.deleteFrom(SYNC_CONFIGS_EVENTS_TABLE)
                .where(SYNC_CONFIGS_EVENTS_TABLE.SYNC_CONFIG_ID.eq(configId))
                .execute()
        }.bind()
        addEvents(configId, events).bind()
    }

    fun addEvents(configId: UUID, events: List<EventDto>): SynciEither<List<EventDto>> = either {
        val queries = events.map {
            val eventUuid = UUID.randomUUID()
            DSL.insertInto(SYNC_CONFIGS_EVENTS_TABLE)
                .columns(
                    SYNC_CONFIGS_EVENTS_TABLE.ID,
                    SYNC_CONFIGS_EVENTS_TABLE.SYNC_CONFIG_ID,
                    SYNC_CONFIGS_EVENTS_TABLE.EVENT_ID,
                    SYNC_CONFIGS_EVENTS_TABLE.SOURCE_EVENT_ID
                )
                .values(eventUuid, configId, it.id, it.sourceId)
        }
        dsl { it.batch(queries).execute() }.bind()
        events
    }

    fun getEventsIdsBySyncConfigId(id: UUID): SynciEither<List<EventsTable>> =
        dsl { it: DSLContext ->
            it
                .select(EVENTS_TABLE.asterisk())
                .from(EVENTS_TABLE)
                .join(SYNC_CONFIGS_EVENTS_TABLE)
                .on(
                    SYNC_CONFIGS_EVENTS_TABLE.SOURCE_EVENT_ID.eq(EVENTS_TABLE.SOURCE_ID)
                        .and(
                            SYNC_CONFIGS_EVENTS_TABLE.EVENT_ID.eq(EVENTS_TABLE.ID)
                        )
                )
                .where(SYNC_CONFIGS_EVENTS_TABLE.SYNC_CONFIG_ID.eq(id))
                .fetchInto(EventsTable::class.java)
        }
}