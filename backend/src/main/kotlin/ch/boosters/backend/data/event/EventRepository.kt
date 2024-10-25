package ch.boosters.backend.data.event

import ch.boosters.backend.data.event.model.Event
import ch.boosters.backend.data.sport.Sport
import ch.boosters.backend.data.sport.SportRepository
import ch.boosters.data.Tables.*
import ch.boosters.data.tables.records.SyncConfigsTeamsTableRecord
import org.jooq.DSLContext
import org.jooq.exception.DataAccessException
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class EventRepository(
    private val dsl: DSLContext,
    private val sportRepository: SportRepository
) {

    fun clearTable(): Boolean {
        try {
            dsl.truncate(EVENTS_TABLE).cascade().execute()
            dsl.truncate(EVENTS_TEAMS_TABLE).cascade().execute()
        } catch (e: DataAccessException) {
            return false
        }
        return true
    }

    fun eventsOfSports(configID: UUID): List<Event> {
        val sportsIds = dsl.selectFrom(SYNC_CONFIGS_SPORTS_TABLE)
            .where(SYNC_CONFIGS_SPORTS_TABLE.SYNC_CONFIG_ID.eq(configID))
            .fetch()
        // get children of sportIds
        val sports = sportsIds.flatMap{ sportRepository.getSubcategoriesById(it.sportId) }

        return sports
            .map { sport -> eventsOfSport(sport)}
            .flatten()
    }

    private fun eventsOfSport(sport: Sport): MutableList<Event> =
        dsl.select().from(EVENTS_TABLE)
            .where(EVENTS_TABLE.SPORT_ID.eq(sport.id))
            .fetch()
            .map {
                Event(
                    it.getValue(EVENTS_TABLE.NAME),
                    it.getValue(EVENTS_TABLE.ID),
                    it.getValue(EVENTS_TABLE.STARTS_ON),
                    it.getValue(EVENTS_TABLE.ENDS_ON)
                )
            }

    fun eventsOfTeams(configID: UUID) : List<Event> {
        val teamIds = dsl.selectFrom(SYNC_CONFIGS_TEAMS_TABLE)
            .where(SYNC_CONFIGS_TEAMS_TABLE.SYNC_CONFIG_ID.eq(configID))
            .fetch()

        return teamIds
            .map (this::eventsOfTeam)
            .flatten()
    }

    private fun eventsOfTeam(team: SyncConfigsTeamsTableRecord): MutableList<Event> =
        dsl.select()
            .from(EVENTS_TABLE)
            .join(EVENTS_TEAMS_TABLE)
            .on(EVENTS_TABLE.ID.eq(EVENTS_TEAMS_TABLE.EVENT_ID))
            .where(EVENTS_TEAMS_TABLE.TEAM_ID.eq(team.teamId))
            .fetch()
            .map {
                Event(
                    it.getValue(EVENTS_TABLE.NAME),
                    it.getValue(EVENTS_TABLE.ID),
                    it.getValue(EVENTS_TABLE.STARTS_ON),
                    it.getValue(EVENTS_TABLE.ENDS_ON)
                )
            }

    fun allEvents(): List<Event> {
        val result = dsl.select().from(EVENTS_TABLE).fetch()

        return result.map {
            Event(
                it.getValue(EVENTS_TABLE.NAME),
                it.getValue(EVENTS_TABLE.ID),
                it.getValue(EVENTS_TABLE.STARTS_ON),
                it.getValue(EVENTS_TABLE.ENDS_ON)
            )
        }
    }
}