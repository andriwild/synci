package ch.boosters.backend.sources.fotmob

import ch.boosters.backend.sources.fotmob.model.FotMobEvent
import ch.boosters.backend.sources.fotmob.model.Team
import ch.boosters.data.Tables.*
import org.jooq.DSLContext
import org.jooq.impl.DSL
import org.springframework.stereotype.Repository

@Repository
class FotMobRepository(private val dsl: DSLContext) {

    fun storeTeams(teams: List<Team>): IntArray {
        dsl.truncate(TEAM).cascade().execute()
        val queries = teams.map { team ->
            dsl.insertInto(TEAM)
                .columns(TEAM.ID, TEAM.SOURCE_ID, TEAM.NAME)
                .values(team.id.toString(), 1, team.name)
        }

        return dsl.batch(queries).execute()
    }

    fun storeEvents(events: List<FotMobEvent>): MutableList<String> {
        dsl.truncate(EVENT).cascade().execute()
        dsl.truncate(EVENT_TEAM).cascade().execute()
        dsl.transaction { config ->
            events.map {
                val transaction = DSL.using(config)
                transaction.newRecord(EVENT).apply {
                    id = it.id.toString()
                    sourceId = 1
                    name = it.name
                    startsOn = it.startsOn
                    endsOn = it.endsOn
                }.store()

            }
        }
        return dsl.select(EVENT.ID).from(EVENT).fetchInto(String::class.java)
    }
}