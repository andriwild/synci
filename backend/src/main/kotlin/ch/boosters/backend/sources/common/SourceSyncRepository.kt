package ch.boosters.backend.sources.common

import arrow.core.raise.either
import arrow.core.raise.ensure
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.data.event.model.TeamEvent
import ch.boosters.backend.data.team.Team
import ch.boosters.backend.errorhandling.ElementNotFound
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.tables.EventsTable.Companion.EVENTS_TABLE
import ch.boosters.data.tables.EventsTeamsTable.Companion.EVENTS_TEAMS_TABLE
import ch.boosters.data.tables.SourcesTable.Companion.SOURCES_TABLE
import ch.boosters.data.tables.TeamsTable.Companion.TEAMS_TABLE
import ch.boosters.data.tables.records.EventsTableRecord
import ch.boosters.data.tables.records.EventsTeamsTableRecord
import org.jooq.impl.DSL
import org.springframework.stereotype.Repository
import java.time.LocalDateTime
import java.util.*

/**
 * Source-independent persistence for team sports: teams, games with their home/away links and
 * the sync timestamp of a source. Mirrors the queries in SwissTxtRepository but takes the source
 * id as a parameter so new sources do not have to copy them.
 */
@Repository
class SourceSyncRepository(private val dsl: JooqEitherDsl) {

    fun sourceIdByName(name: String): SynciEither<Int> = either {
        val id = dsl {
            it.select(SOURCES_TABLE.ID).from(SOURCES_TABLE).where(SOURCES_TABLE.NAME.eq(name)).fetchOne(SOURCES_TABLE.ID)
        }.bind()
        ensure(id != null) { ElementNotFound("Source '$name' not found in sources_table") }
        id
    }

    fun upsertTeams(teams: List<Team>): SynciEither<IntArray> {
        val queries = teams.map { team ->
            DSL.insertInto(TEAMS_TABLE)
                .values(team.id, team.source, team.name, team.gender)
                .onDuplicateKeyUpdate()
                .set(TEAMS_TABLE.NAME, team.name)
        }
        return dsl { it.batch(queries).execute() }
    }

    /**
     * Inserts or updates the games of one sport node and links both teams to every game.
     * [nameOf] builds the event name; default is the Synci convention "Home - Away".
     */
    fun upsertTeamEvents(
        sourceId: Int,
        sportId: UUID,
        events: List<TeamEvent>,
        nameOf: (TeamEvent) -> String = { "${it.homeName} - ${it.awayName}" },
    ): SynciEither<Unit> {
        val eventQueries = events.map { event ->
            val record = EventsTableRecord(
                id = event.id,
                sourceId = sourceId,
                name = nameOf(event),
                startsOn = event.startsOn,
                endsOn = event.endsOn,
                sportId = sportId,
            )
            DSL.insertInto(EVENTS_TABLE)
                .set(record)
                .onDuplicateKeyUpdate()
                .set(EVENTS_TABLE.NAME, record.name)
                .set(EVENTS_TABLE.STARTS_ON, record.startsOn)
                .set(EVENTS_TABLE.ENDS_ON, record.endsOn)
        }
        val linkQueries = events.flatMap { event ->
            listOf(event.homeId, event.awayId).map { teamId ->
                DSL.insertInto(EVENTS_TEAMS_TABLE).set(
                    EventsTeamsTableRecord(
                        id = UUID.randomUUID(),
                        eventId = event.id,
                        sourceEventId = sourceId,
                        teamId = teamId,
                        sourceTeamId = sourceId,
                    )
                ).onDuplicateKeyIgnore()
            }
        }
        return dsl { jooq ->
            jooq.batch(eventQueries).execute()
            jooq.batch(linkQueries).execute()
            Unit
        }
    }

    fun lastSyncTime(sourceId: Int): SynciEither<LocalDateTime?> =
        dsl { it.fetchOne(lastSyncTimeQuery(sourceId))?.get(SOURCES_TABLE.LAST_SYNC) }

    fun storeSyncTime(sourceId: Int): SynciEither<Int> =
        dsl { it.execute(storeSyncTimeQuery(sourceId)) }
}
