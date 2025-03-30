package ch.boosters.backend.data.event

import arrow.core.Either
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.backend.errorhandling.SynciError
import ch.boosters.data.tables.EventsTable.Companion.EVENTS_TABLE
import ch.boosters.data.tables.EventsTeamsTable.Companion.EVENTS_TEAMS_TABLE
import ch.boosters.data.tables.SportsTable.Companion.SPORTS_TABLE
import ch.boosters.data.tables.SyncConfigsEventsTable.Companion.SYNC_CONFIGS_EVENTS_TABLE
import ch.boosters.data.tables.SyncConfigsSportsTable.Companion.SYNC_CONFIGS_SPORTS_TABLE
import ch.boosters.data.tables.SyncConfigsTable.Companion.SYNC_CONFIGS_TABLE
import ch.boosters.data.tables.pojos.EventsTable
import org.jooq.DSLContext
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class EventRepository(private val dsl: JooqEitherDsl) {

    fun clearTable(): Either<SynciError, Unit> = dsl {
        it.truncate(EVENTS_TABLE).cascade().execute()
        it.truncate(EVENTS_TEAMS_TABLE).cascade().execute()
    }

    fun eventsByConfig(configID: UUID): SynciEither<List<EventsTable>> =
        dsl {
            it.select(EVENTS_TABLE.asterisk())
                .from(EVENTS_TABLE)
                .join(SYNC_CONFIGS_EVENTS_TABLE)
                .on(SYNC_CONFIGS_EVENTS_TABLE.EVENT_ID.eq(EVENTS_TABLE.ID))
                .where(SYNC_CONFIGS_EVENTS_TABLE.SYNC_CONFIG_ID.eq(configID))
                .fetch().into(EventsTable::class.java)
        }

    fun eventsOfTeams(configID: UUID): SynciEither<List<EventsTable>> =
        dsl {
            it.select(EVENTS_TABLE.asterisk()).from(EVENTS_TABLE)
                .join(SYNC_CONFIGS_EVENTS_TABLE)
                .on(SYNC_CONFIGS_EVENTS_TABLE.EVENT_ID.eq(EVENTS_TABLE.ID))
                .join(SYNC_CONFIGS_TABLE)
                .on(SYNC_CONFIGS_TABLE.ID.eq(SYNC_CONFIGS_EVENTS_TABLE.SYNC_CONFIG_ID))
                .where(SYNC_CONFIGS_TABLE.ID.eq(configID))
                .fetch()
                .into(EventsTable::class.java)
        }

    fun sportsByConfig(id: UUID): SynciEither<List<UUID>> =
        dsl { it: DSLContext ->
            it.select(SPORTS_TABLE.ID)
                .from(SPORTS_TABLE)
                .join(SYNC_CONFIGS_SPORTS_TABLE)
                .on(SYNC_CONFIGS_SPORTS_TABLE.SPORT_ID.eq(SPORTS_TABLE.ID))
                .where(SYNC_CONFIGS_SPORTS_TABLE.SYNC_CONFIG_ID.eq(id))
                .fetchInto(UUID::class.java)
        }

    fun eventsBySports(ids: List<UUID>): SynciEither<List<EventsTable>> =
        dsl { it: DSLContext ->
            it
                .select(EVENTS_TABLE.asterisk())
                .from(EVENTS_TABLE)
                .where(EVENTS_TABLE.SPORT_ID.`in`(ids))
                .fetchInto(EventsTable::class.java)
        }
}