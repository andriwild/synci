package ch.boosters.backend.sources.common

import ch.boosters.data.Tables.EVENTS_TABLE
import ch.boosters.data.Tables.SOURCES_TABLE
import ch.boosters.data.Tables.TEAMS_TABLE
import org.jooq.Query
import org.jooq.Record1
import org.jooq.SelectConditionStep
import org.jooq.impl.DSL
import java.time.LocalDateTime

fun storeSyncTimeQuery(sourceId: Int): Query {
    return DSL.update(SOURCES_TABLE)
        .set(SOURCES_TABLE.LAST_SYNC, LocalDateTime.now())
        .where(SOURCES_TABLE.ID.eq(sourceId))

}

fun lastSyncTimeQuery(sourceId: Int): SelectConditionStep<Record1<LocalDateTime>> {
    return DSL.select(SOURCES_TABLE.LAST_SYNC)
        .from(SOURCES_TABLE)
        .where(SOURCES_TABLE.ID.eq(sourceId))
}

fun deleteDataBySource(sourceId: Int) =
    listOf(
        DSL
            .deleteFrom(EVENTS_TABLE)
            .where(EVENTS_TABLE.SOURCE_ID.eq(sourceId)),
        DSL
            .deleteFrom(TEAMS_TABLE)
            .where(TEAMS_TABLE.SOURCE_ID.eq(sourceId))
    )