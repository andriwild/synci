package ch.boosters.backend.data.syncConfig

import ch.boosters.backend.data.event.EventResponse
import ch.boosters.data.tables.pojos.SportsTable
import ch.boosters.backend.data.team.TeamResponse
import com.fasterxml.jackson.annotation.JsonUnwrapped
import java.util.UUID

data class WithRootSport<T>(
    @get:JsonUnwrapped val item: T,
    val rootSport: String?
)

/** A Top Event: every game between the two teams. */
data class MatchupResponse(
    val sourceId: Int,
    val teamA: TeamResponse,
    val teamB: TeamResponse,
)

data class SyncConfig (
    val id: UUID?,
    val name: String,
    val teams: List<WithRootSport<TeamResponse>>,
    val sports: List<WithRootSport<SportsTable>>,
    val events: List<WithRootSport<EventResponse>>,
    val matchups: List<WithRootSport<MatchupResponse>>,
    /** how many Top Events the Abo may hold */
    val matchupLimit: Int,
)
