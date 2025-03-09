package ch.boosters.backend.data.event

import arrow.core.Either
import arrow.core.raise.either
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.data.event.model.Event
import ch.boosters.backend.data.sport.SportsRepository
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.backend.errorhandling.SynciError
import ch.boosters.data.Tables.*
import ch.boosters.data.tables.pojos.SportsTable
import ch.boosters.data.tables.pojos.SyncConfigsTeamsTable
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class EventRepository(
    private val dsl: JooqEitherDsl,
    private val sportRepository: SportsRepository
) {

    fun clearTable(): Either<SynciError, Unit> = dsl {
        it.truncate(EVENTS_TABLE).cascade().execute()
        it.truncate(EVENTS_TEAMS_TABLE).cascade().execute()
    }

    fun eventsOfSports(configID: UUID): SynciEither<List<Event>> = either {
        val sportsIds = dsl {
            it.selectFrom(SYNC_CONFIGS_SPORTS_TABLE)
                .where(SYNC_CONFIGS_SPORTS_TABLE.SYNC_CONFIG_ID.eq(configID))
                .fetch()
        }.bind()
        // get children of sportIds
        val sports = sportsIds.flatMap {
            sportRepository
                .subcategoriesById(it.sportId)
                .bind()
        }
        sports
            .map { sport -> eventsOfSport(sport).bind() }
            .flatten()
    }

    private fun eventsOfSport(sport: SportsTable): SynciEither<MutableList<Event>> =
        dsl {
            it.select().from(EVENTS_TABLE)
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
        }

    fun eventsOfTeams(configID: UUID): SynciEither<List<Event>> = either {
        val teams = dsl {
            it.selectFrom(SYNC_CONFIGS_TEAMS_TABLE)
                .where(SYNC_CONFIGS_TEAMS_TABLE.SYNC_CONFIG_ID.eq(configID))
                .fetch()
                .into(SyncConfigsTeamsTable::class.java)
        }.bind()

        teams
            .map { eventsOfTeam(it) }
            .bindAll()
            .flatten()
    }

    private fun eventsOfTeam(team: SyncConfigsTeamsTable): SynciEither<MutableList<Event>> =
        dsl {
            it.select()
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
        }

    fun allEvents(): SynciEither<List<Event>> = either {
        val result = dsl { it.select().from(EVENTS_TABLE).fetch() }.bind()

        result.map {
            Event(
                it.getValue(EVENTS_TABLE.NAME),
                it.getValue(EVENTS_TABLE.ID),
                it.getValue(EVENTS_TABLE.STARTS_ON),
                it.getValue(EVENTS_TABLE.ENDS_ON)
            )
        }
    }
}