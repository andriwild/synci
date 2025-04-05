package ch.boosters.backend.sources.swisstxt

import arrow.core.Either
import arrow.core.raise.either
import arrow.core.raise.ensure
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.data.team.Team
import ch.boosters.backend.errorhandling.DatabaseError
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.backend.sources.common.deleteDataBySource
import ch.boosters.backend.sources.common.lastSyncTimeQuery
import ch.boosters.backend.sources.swisstxt.model.SwissTxtTeamEvent
import ch.boosters.data.tables.EventsTable.Companion.EVENTS_TABLE
import ch.boosters.data.tables.EventsTeamsTable
import ch.boosters.data.tables.SourcesTable.Companion.SOURCES_TABLE
import ch.boosters.data.tables.SportsTable.Companion.SPORTS_TABLE
import ch.boosters.data.tables.TeamsTable.Companion.TEAMS_TABLE
import org.jooq.DSLContext
import org.jooq.impl.DSL
import org.springframework.stereotype.Repository
import java.time.LocalDateTime
import java.util.*

@Repository
class SwissTxtRepository(
    private val dsl: JooqEitherDsl,
    private val swissTxtConfig: SwissTxtConfig,
) {
    val sourceId: SynciEither<Int> by lazy {
        initSourceId()
    }

    fun deleteSwissTxtData(): SynciEither<List<Int>> = either {
        val sourceId = sourceId.bind()
        dsl { db: DSLContext ->
            deleteDataBySource(sourceId).map { db.execute(it) }
        }.bind()
    }

    fun storeTeams(teams: List<Team>): SynciEither<IntArray> = either {
        val id = sourceId.bind()
        val queries = teams.map { team ->
            DSL.insertInto(TEAMS_TABLE)
                .columns(TEAMS_TABLE.ID, TEAMS_TABLE.SOURCE_ID, TEAMS_TABLE.NAME)
                .values(team.id, id, team.name)
                .onConflict()
                .doNothing()
        }

        return dsl { it.batch(queries).execute() }
    }


    fun storeEvents(sportKey: String, events: List<SwissTxtTeamEvent>): SynciEither<List<String>> = either {
        val sportId = getSportId(sportKey).bind()
        val srcId = sourceId.bind()

        dsl { jooq ->

            events.forEach {
                val eventName = "${it.homeName} - ${it.awayName}"
                val eventRecord = jooq.newRecord(EVENTS_TABLE).apply {
                    id = it.id.toString()
                    sourceId = srcId
                    name = eventName
                    startsOn = it.startsOn
                    endsOn = it.endsOn
                    this.sportId = sportId
                }
                eventRecord.store()

                val eventTeamRecord = jooq.newRecord(EventsTeamsTable.EVENTS_TEAMS_TABLE).apply {
                    id = UUID.randomUUID()
                    eventId = it.id.toString()
                    sourceEventId = srcId
                    teamId = it.homeId
                    sourceTeamId = srcId
                }
                val eventTeamRecord2 = jooq.newRecord(EventsTeamsTable.EVENTS_TEAMS_TABLE).apply {
                    id = UUID.randomUUID()
                    eventId = it.id.toString()
                    sourceEventId = srcId
                    teamId = it.awayId
                    sourceTeamId = srcId
                }
                jooq.batchStore(eventTeamRecord, eventTeamRecord2).execute()
            }
            jooq.select(EVENTS_TABLE.ID).from(EVENTS_TABLE).fetchInto(String::class.java)
        }.bind()

    }

    fun storeSyncTime() = either {
        val sourceId = sourceId.bind()
        dsl {
            it.update(SOURCES_TABLE)
                .set(SOURCES_TABLE.LAST_SYNC, LocalDateTime.now())
                .where(SOURCES_TABLE.ID.eq(sourceId))
                .execute()
        }
    }

    fun lastSyncTime(): SynciEither<LocalDateTime?> = either {
        val sourceId = sourceId.bind()

        dsl {
            val q = lastSyncTimeQuery(sourceId)
            it.fetchOne(q)?.get(SOURCES_TABLE.LAST_SYNC)
        }.bind()
    }

    private fun initSourceId(): SynciEither<Int> = either {
        val result = dsl {
            it.select()
                .from(SOURCES_TABLE)
                .where(SOURCES_TABLE.NAME.eq(swissTxtConfig.name))
                .fetchOne(SOURCES_TABLE.ID)
        }.bind()
        // TODO: use a different error, as Databaseerror is for fatal db errors
        ensure(result != null) { DatabaseError("Id not found") }
        result
    }

    private fun getSportId(sportKey: String): Either<DatabaseError, UUID?> {
        return dsl {
            it.select()
                .from(SPORTS_TABLE)
                .where(SPORTS_TABLE.NAME.eq(sportKey))
                .fetchOne(SPORTS_TABLE.ID)
        }
    }
}