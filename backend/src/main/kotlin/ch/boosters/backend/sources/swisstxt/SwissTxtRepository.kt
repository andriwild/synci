package ch.boosters.backend.sources.swisstxt

import arrow.core.Either
import arrow.core.raise.either
import arrow.core.raise.ensure
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.data.event.model.Event
import ch.boosters.backend.data.event.model.TeamEvent
import ch.boosters.backend.data.team.Team
import ch.boosters.backend.errorhandling.DatabaseError
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.backend.errorhandling.SynciError
import ch.boosters.backend.sources.common.lastSyncTimeQuery
import ch.boosters.data.tables.EventsTable.Companion.EVENTS_TABLE
import ch.boosters.data.tables.SourcesTable.Companion.SOURCES_TABLE
import ch.boosters.data.tables.SportsTable.Companion.SPORTS_TABLE
import ch.boosters.data.tables.TeamsTable.Companion.TEAMS_TABLE
import ch.boosters.data.tables.records.EventsTableRecord
import ch.boosters.data.tables.records.EventsTeamsTableRecord
import org.jooq.DSLContext
import org.jooq.InsertOnDuplicateSetMoreStep
import org.jooq.impl.DSL
import org.springframework.stereotype.Repository
import java.time.LocalDateTime
import java.util.*

@Repository
class SwissTxtRepository(
    private val dsl: JooqEitherDsl,
    private val swissTxtConfig: SwissTxtConfig,
) {
    val swissTxtId: SynciEither<Int> by lazy {
        initSourceId()
    }

    fun upsertTeams(teams: List<Team>): SynciEither<IntArray> = either {
        val sourceId = swissTxtId.bind()
        val queries = teams.map { team ->
            DSL
                .insertInto(TEAMS_TABLE)
                .columns(TEAMS_TABLE.ID, TEAMS_TABLE.SOURCE_ID, TEAMS_TABLE.NAME)
                .values(team.id, sourceId, team.name)
                .onDuplicateKeyUpdate()
                .set(TEAMS_TABLE.NAME, team.name)
        }
        return dsl { it.batch(queries).execute() }
    }

    fun upsertEvents(sportKey: String, events: List<TeamEvent>): SynciEither<List<String>> = either {
        val sportId = getSportId(sportKey).bind()
        val srcId = swissTxtId.bind()

        val queries = events.map { createEventQueries(it, srcId, sportId) }

        dsl { jooq ->
            jooq.batch(queries.map { it.first }).execute()
            jooq.batchStore(queries.flatMap { it.second }).execute()
            jooq.select(EVENTS_TABLE.ID).from(EVENTS_TABLE).fetchInto(String::class.java)
        }.bind()
    }

    private fun createEventQueries(
        event: TeamEvent,
        srcId: Int,
        sportId: UUID?
    ): Pair<InsertOnDuplicateSetMoreStep<EventsTableRecord?>, List<EventsTeamsTableRecord>> {
        val eventRecord = createEvent(event, srcId, sportId)
        val eventQuery = eventQuery(eventRecord)
        val (eventTeamRecord, eventTeamRecord2) = linkTeamsToEvents(event, srcId)
        return Pair(eventQuery, listOf(eventTeamRecord, eventTeamRecord2))
    }

    private fun createEvent(
        event: TeamEvent,
        srcId: Int,
        sportId: UUID?
    ): EventsTableRecord {
        val eventName = "${event.homeName} - ${event.awayName}"
        return EventsTableRecord(
            id = event.id,
            sourceId = srcId,
            name = eventName,
            startsOn = event.startsOn,
            endsOn = event.endsOn,
            sportId = sportId
        )
    }

    private fun linkTeamsToEvents(
        event: TeamEvent, srcId: Int
    ): Pair<EventsTeamsTableRecord, EventsTeamsTableRecord> {
        val eventTeamRecord = EventsTeamsTableRecord(
            id = UUID.randomUUID(),
            eventId = event.id,
            sourceEventId = srcId,
            teamId = event.homeId,
            sourceTeamId = srcId
        )
        val eventTeamRecord2 = EventsTeamsTableRecord(
            id = UUID.randomUUID(),
            eventId = event.id,
            sourceEventId = srcId,
            teamId = event.awayId,
            sourceTeamId = srcId
        )
        return Pair(eventTeamRecord, eventTeamRecord2)
    }

    private fun eventQuery(eventRecord: EventsTableRecord): InsertOnDuplicateSetMoreStep<EventsTableRecord?> =
        DSL
            .insertInto(EVENTS_TABLE)
            .set(eventRecord)
            .onDuplicateKeyUpdate()
            .set(EVENTS_TABLE.NAME, eventRecord.name)
            .set(EVENTS_TABLE.STARTS_ON, eventRecord.startsOn)
            .set(EVENTS_TABLE.ENDS_ON, eventRecord.endsOn)

    fun upsertEvents(id: Int, sportId: UUID, events: List<Event>): Either<SynciError, Unit> = either {
        dsl { it: DSLContext ->
            events.forEach { event ->
                it.newRecord(EVENTS_TABLE).apply {
                    this.id = UUID.randomUUID().toString()
                    name = event.name
                    sourceId = id
                    startsOn = event.startsOn
                    this.sportId = sportId
                }.store()
            }
        }.bind()
    }

    fun storeSyncTime() = either {
        val sourceId = swissTxtId.bind()
        dsl {
            it.update(SOURCES_TABLE).set(SOURCES_TABLE.LAST_SYNC, LocalDateTime.now())
                .where(SOURCES_TABLE.ID.eq(sourceId)).execute()
        }
    }

    fun lastSyncTime(): SynciEither<LocalDateTime?> = either {
        val sourceId = swissTxtId.bind()

        dsl {
            val q = lastSyncTimeQuery(sourceId)
            it.fetchOne(q)?.get(SOURCES_TABLE.LAST_SYNC)
        }.bind()
    }

    private fun initSourceId(): SynciEither<Int> = either {
        val result = dsl {
            it.select().from(SOURCES_TABLE).where(SOURCES_TABLE.NAME.eq(swissTxtConfig.name)).fetchOne(SOURCES_TABLE.ID)
        }.bind()
        // TODO: use a different error, as Databaseerror is for fatal db errors
        ensure(result != null) { DatabaseError("Id not found") }
        result
    }

    private fun getSportId(sportKey: String): Either<DatabaseError, UUID?> {
        return dsl {
            it.select().from(SPORTS_TABLE).where(SPORTS_TABLE.NAME.eq(sportKey)).fetchOne(SPORTS_TABLE.ID)
        }
    }
}