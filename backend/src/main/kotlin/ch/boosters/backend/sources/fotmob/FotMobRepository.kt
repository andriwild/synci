package ch.boosters.backend.sources.fotmob

import ch.boosters.backend.sources.fotmob.model.FotMobEvent
import ch.boosters.backend.sources.fotmob.model.Team
import ch.boosters.data.Tables.TEAMS_TABLE
import ch.boosters.data.Tables.EVENTS_TABLE
import ch.boosters.data.Tables.EVENTS_TEAMS_TABLE
import org.jooq.DSLContext
import org.jooq.impl.DSL
import org.springframework.stereotype.Repository

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
        dsl.transaction { config ->
            events.map {
                val transaction = DSL.using(config)
                transaction.newRecord(EVENTS_TABLE).apply {
                    id = it.id.toString()
                    sourceId = 1
                    name = it.name
                    startsOn = it.startsOn
                    endsOn = it.endsOn
                }.store()

            }
        }
        return dsl.select(EVENTS_TABLE.ID).from(EVENTS_TABLE).fetchInto(String::class.java)
    }
}