package ch.boosters.backend.data.event

import ch.boosters.backend.data.team.TeamResponse
import ch.boosters.data.tables.pojos.EventsTable
import ch.boosters.data.tables.pojos.TeamsTable
import com.fasterxml.jackson.annotation.JsonUnwrapped

/** An event as returned to clients: the stored event plus its teams, empty for events without teams. */
data class EventResponse(
    @get:JsonUnwrapped val event: EventsTable,
    val teams: List<TeamResponse>,
) {
    companion object {
        /** Orders the teams like the event name ("Home - Away"); teams not named in it come last. */
        fun of(event: EventsTable, teams: List<TeamsTable>) = EventResponse(
            event = event,
            teams = teams.distinctBy { it.id }
                .sortedBy { team -> event.name.indexOf(team.name, ignoreCase = true).takeIf { it >= 0 } ?: Int.MAX_VALUE }
                .map(TeamResponse::of),
        )
    }
}
