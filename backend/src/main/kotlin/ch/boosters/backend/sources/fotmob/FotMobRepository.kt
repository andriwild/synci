package ch.boosters.backend.sources.fotmob

import ch.boosters.backend.sources.SourceConfig
import ch.boosters.backend.sources.fotmob.model.FotMobEvent
import ch.boosters.backend.sources.fotmob.model.Team
import ch.boosters.data.Tables.*
import org.jooq.DSLContext
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class FotMobRepository(
    private val dsl: DSLContext,
    private val sourceConfig: SourceConfig,
) {

    var sourceId: Int? = null

    fun getSourceId(): Int {
        if (sourceId != null) return sourceId as Int

       val id = dsl.select()
           .from(SOURCES_TABLE)
           .where(SOURCES_TABLE.NAME.eq(sourceConfig.fotmob.name))
           .fetchOne(SOURCES_TABLE.ID)
        sourceId = id as Int
        return id
    }

    fun clearTables() {
        dsl.truncate(EVENTS_TABLE).cascade().execute()
        dsl.truncate(EVENTS_TEAMS_TABLE).cascade().execute()
        dsl.truncate(TEAMS_TABLE).cascade().execute()
    }

    fun storeTeams(teams: List<Team>): IntArray {
        val queries = teams.map { team ->
            dsl.insertInto(TEAMS_TABLE).columns().values(team.id.toString(), getSourceId(), team.name)
            dsl.insertInto(TEAMS_TABLE)
                .columns(TEAMS_TABLE.ID, TEAMS_TABLE.SOURCE_ID, TEAMS_TABLE.NAME)
                .values(team.id.toString(), getSourceId(), team.name)
                .onConflict()
                .doNothing()
        }

        return dsl.batch(queries).execute()
    }

    fun storeEvents(events: List<FotMobEvent>): MutableList<String> {
            events.forEach {
                val eventRecord = dsl.newRecord(EVENTS_TABLE)
                eventRecord.setId(it.id.toString())
                eventRecord.setSourceId(getSourceId())
                eventRecord.setName(it.name)
                eventRecord.setStartsOn(it.startsOn)
                eventRecord.setEndsOn(it.endsOn)
                eventRecord.store()

                val eventTeamRecord = dsl.newRecord(EVENTS_TEAMS_TABLE)
                eventTeamRecord.setId(UUID.randomUUID())
                eventTeamRecord.setEventId(it.id.toString())
                eventTeamRecord.setSourceEventId(getSourceId())
                eventTeamRecord.setTeamId(it.homeId)
                eventTeamRecord.setSourceTeamId(getSourceId())
                eventTeamRecord.store()

                val eventTeamRecord2 = dsl.newRecord(EVENTS_TEAMS_TABLE)
                eventTeamRecord2.setId(UUID.randomUUID())
                eventTeamRecord2.setEventId(it.id.toString())
                eventTeamRecord2.setSourceEventId(getSourceId())
                eventTeamRecord2.setTeamId(it.awayId)
                eventTeamRecord2.setSourceTeamId(getSourceId())
                eventTeamRecord2.store()
        }
        return dsl.select(EVENTS_TABLE.ID).from(EVENTS_TABLE).fetchInto(String::class.java)
    }
}
