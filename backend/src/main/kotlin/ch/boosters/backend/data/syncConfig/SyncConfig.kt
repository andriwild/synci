package ch.boosters.backend.data.syncConfig

import ch.boosters.data.tables.pojos.EventsTable
import ch.boosters.data.tables.pojos.SportsTable
import ch.boosters.data.tables.pojos.TeamsTable
import com.fasterxml.jackson.annotation.JsonUnwrapped
import java.util.UUID

data class WithRootSport<T>(
    @get:JsonUnwrapped val item: T,
    val rootSport: String?
)

data class SyncConfig (
    val id: UUID?,
    val name: String,
    val teams: List<WithRootSport<TeamsTable>>,
    val sports: List<WithRootSport<SportsTable>>,
    val events: List<WithRootSport<EventsTable>>
)
