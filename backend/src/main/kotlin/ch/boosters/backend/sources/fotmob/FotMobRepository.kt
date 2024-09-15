package ch.boosters.backend.sources.fotmob

import ch.boosters.backend.sources.fotmob.model.FotMobEvent
import ch.boosters.backend.sources.fotmob.model.Team
import ch.boosters.data.Tables.TEAMS_TABLE
import ch.boosters.data.Tables.EVENTS_TABLE
import ch.boosters.data.Tables.EVENTS_TEAMS_TABLE
import org.jooq.DSLContext
import org.jooq.impl.DSL
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class FotMobRepository(private val dsl: DSLContext) {

    fun storeTeams(teams: List<Team>): IntArray {
        dsl.truncate(TEAMS_TABLE).cascade().execute()
        val queries = teams.map { team ->
            dsl.insertInto(TEAMS_TABLE)
                .columns(TEAMS_TABLE.ID, TEAMS_TABLE.SOURCE_ID, TEAMS_TABLE.NAME)
                .values(team.id.toString(), 1, team.name)
        }

        return dsl.batch(queries).execute()
    }

    fun storeEvents(events: List<FotMobEvent>): MutableList<String> {
        dsl.truncate(EVENTS_TABLE).cascade().execute()
        dsl.truncate(EVENTS_TEAMS_TABLE).cascade().execute()
//        dsl.transaction { config ->
            events.forEach {
                val transaction = dsl

                val eventRecord = dsl.newRecord(EVENTS_TABLE)
                eventRecord.setId(it.id.toString())
                eventRecord.setSourceId(1)
                eventRecord.setName(it.name)
                eventRecord.setStartsOn(it.startsOn)
                eventRecord.setEndsOn(it.endsOn)
                eventRecord.store()

                val eventTeamRecord = dsl.newRecord(EVENTS_TEAMS_TABLE);
                eventTeamRecord.setId(UUID.randomUUID());
                eventTeamRecord.setEventId(it.id.toString())
                eventTeamRecord.setSourceEventId(1);
                eventTeamRecord.setTeamId(it.homeId);
                eventTeamRecord.setSourceTeamId(1);
                eventTeamRecord.store()

                val eventTeamRecord2 = dsl.newRecord(EVENTS_TEAMS_TABLE);
                eventTeamRecord2.setId(UUID.randomUUID());
                eventTeamRecord2.setEventId(it.id.toString())
                eventTeamRecord2.setSourceEventId(1);
                eventTeamRecord2.setTeamId(it.awayId);
                eventTeamRecord2.setSourceTeamId(1);
                eventTeamRecord2.store()
            //                transaction.insertInto(EVENTS_TABLE).values(it.id.toString(), 1, it.name, it.startsOn, it.endsOn)

//                transaction.insertInto(EVENTS_TEAMS_TABLE).values(UUID.randomUUID(), it.id.toString(), 1, it.homeId, 1 )
//                transaction.insertInto(EVENTS_TEAMS_TABLE).values(UUID.randomUUID(), it.id.toString(), 1, it.awayId, 1 )
//                transaction.newRecord(EVENTS_TABLE).apply {
////                    id = it.id.toString()
////                    sourceId = 1
////                    name = it.name
////                    startsOn = it.startsOn
////                    endsOn = it.endsOn
//                }.store()
//
//                transaction.newRecord(EVENTS_TEAMS_TABLE).apply {
//                    it.id.toString(), 1, it.homeId, 1, }
//
//            }
        }
        return dsl.select(EVENTS_TABLE.ID).from(EVENTS_TABLE).fetchInto(String::class.java)
    }
}