package ch.boosters.backend.sources.swissski

import arrow.core.raise.either
import arrow.core.raise.ensure
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.errorhandling.DatabaseError
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.backend.sources.common.lastSyncTimeQuery
import ch.boosters.backend.sources.common.storeSyncTimeQuery
import ch.boosters.backend.sources.swissski.model.SwissSkiEvent
import ch.boosters.data.Tables.*
import org.springframework.stereotype.Repository
import java.time.LocalDateTime
import java.util.*

@Repository
class SwissSkiRepository(
    private val dsl: JooqEitherDsl,
    private val swissSkiConfig: SwissSkiConfig,
) {

    val sourceId: SynciEither<Int> by lazy {
        initSourceId()
    }

    fun storeEvents(events: List<SwissSkiEvent>): SynciEither<List<Int>> = either {
        val stored = events
            .map { Pair(it, findSportId(it)) }
            .filter { it.second.isRight() }
            .map { storeEvent(it.first, it.second.bind()) }
        stored.bindAll()
    }

    fun storeSyncTime(): SynciEither<Unit> = either {
        val id = sourceId.bind()
        dsl {
            val q = storeSyncTimeQuery(id)
            it.execute(q)
        }.bind()
    }

    fun lastSyncTime(): SynciEither<LocalDateTime?> = either {
        val id = sourceId.bind()
        dsl {
            val q = lastSyncTimeQuery(id)
            it.fetchOne(q)?.get(SOURCES_TABLE.LAST_SYNC)
        }.bind()
    }

    private fun storeEvent(event: SwissSkiEvent, sportId: UUID): SynciEither<Int> = either {
        val id = sourceId.bind()
        val x = dsl {
            it.newRecord(EVENTS_TABLE)
                .setId(UUID.randomUUID().toString())
                .setName(event.place)
                .setSourceId(id)
                .setStartsOn(event.raceDate)
                .setSportId(sportId)
                .store()
        }
        x.bind()
    }

    private fun initSourceId(): SynciEither<Int> = either {
        val id = dsl {
            it.select()
                .from(SOURCES_TABLE)
                .where(SOURCES_TABLE.NAME.eq(swissSkiConfig.name))
                .fetchOne(SOURCES_TABLE.ID)
        }.bind()
        // TODO: use a different error here, as databaseerror should only be used for fatal errors
        ensure (id != null) { DatabaseError("") }
        id
    }

    private fun findSportId(event: SwissSkiEvent): SynciEither<UUID> = either {
        val sportsName = "${event.catCode}_${event.disciplineCode}_${event.gender}"
        val sportId = dsl {
            it.select()
                .from(SPORTS_TABLE)
                .where(SPORTS_TABLE.NAME.eq(sportsName))
                .fetchOne(SPORTS_TABLE.ID)
        }.bind()
        // TODO: use a different error here, as databaseerror should only be used for fatal errors
        ensure (sportId != null) { DatabaseError("Could not find an id to sport $sportsName") }
        sportId
    }
}