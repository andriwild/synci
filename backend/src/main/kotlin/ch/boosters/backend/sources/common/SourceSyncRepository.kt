package ch.boosters.backend.sources.common

import arrow.core.raise.either
import arrow.core.raise.ensure
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.data.event.model.Event
import ch.boosters.backend.data.event.model.TeamEvent
import ch.boosters.backend.data.team.Team
import ch.boosters.backend.errorhandling.ElementNotFound
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.tables.EventsTable.Companion.EVENTS_TABLE
import ch.boosters.data.tables.EventsTeamsTable.Companion.EVENTS_TEAMS_TABLE
import ch.boosters.data.tables.SourcesTable.Companion.SOURCES_TABLE
import ch.boosters.data.tables.SportsTable.Companion.SPORTS_TABLE
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
            DSL.insertInto(TEAMS_TABLE, TEAMS_TABLE.ID, TEAMS_TABLE.SOURCE_ID, TEAMS_TABLE.NAME, TEAMS_TABLE.GENDER, TEAMS_TABLE.LOGO_URL)
                .values(team.id, team.source, team.name, team.gender.toGenderType(), team.logoUrl)
                .onDuplicateKeyUpdate()
                .set(TEAMS_TABLE.NAME, team.name)
                // a sync without logo keeps the one stored earlier
                .set(TEAMS_TABLE.LOGO_URL, DSL.coalesce(DSL.`val`(team.logoUrl), TEAMS_TABLE.LOGO_URL))
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

    /**
     * Creates the sport node [name] below [parentName] or updates its label. Used for nodes that come
     * and go with the source (e.g. e-sport leagues), so they need no migration. Returns the node id.
     */
    fun upsertSportNode(name: String, label: String, parentName: String): SynciEither<UUID> = either {
        val parentId = dsl {
            it.select(SPORTS_TABLE.ID).from(SPORTS_TABLE).where(SPORTS_TABLE.NAME.eq(parentName)).fetchOne(SPORTS_TABLE.ID)
        }.bind()
        ensure(parentId != null) { ElementNotFound("Parent sport '$parentName' not found") }
        dsl {
            it.insertInto(SPORTS_TABLE)
                .set(SPORTS_TABLE.ID, UUID.randomUUID())
                .set(SPORTS_TABLE.NAME, name)
                .set(SPORTS_TABLE.LABEL, label)
                .set(SPORTS_TABLE.PARENT_ID, parentId)
                .onConflict(SPORTS_TABLE.NAME)
                .doUpdate()
                .set(SPORTS_TABLE.LABEL, label)
                .returningResult(SPORTS_TABLE.ID)
                .fetchOne()!!
                .value1()!!
        }.bind()
    }

    /** Removes events of a source, e.g. matches that were canceled. Team and subscription links cascade. */
    fun deleteEvents(sourceId: Int, ids: Collection<String>): SynciEither<Int> =
        if (ids.isEmpty()) arrow.core.Either.Right(0)
        else dsl { it.deleteFrom(EVENTS_TABLE).where(EVENTS_TABLE.SOURCE_ID.eq(sourceId)).and(EVENTS_TABLE.ID.`in`(ids)).execute() }

    /** Inserts or updates events without teams (e.g. matches whose opponents are not known yet). */
    fun upsertEvents(sourceId: Int, sportId: UUID, events: List<Event>): SynciEither<IntArray> {
        val queries = events.map { event ->
            val record = EventsTableRecord(
                id = event.id,
                sourceId = sourceId,
                name = event.name,
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
                .set(EVENTS_TABLE.SPORT_ID, record.sportId)
        }
        return dsl { it.batch(queries).execute() }
    }

    fun lastSyncTime(sourceId: Int): SynciEither<LocalDateTime?> =
        dsl { it.fetchOne(lastSyncTimeQuery(sourceId))?.get(SOURCES_TABLE.LAST_SYNC) }

    fun storeSyncTime(sourceId: Int): SynciEither<Int> =
        dsl { it.execute(storeSyncTimeQuery(sourceId)) }
}
