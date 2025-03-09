package ch.boosters.backend.data.syncConfig

import ch.boosters.data.tables.pojos.EventsTable
import ch.boosters.data.tables.pojos.SportsTable
import ch.boosters.data.tables.pojos.TeamsTable
import java.util.UUID

data class SyncConfig (
    val id: UUID?,
    val name: String,
    val teams: List<TeamsTable>,
    val sports: List<SportsTable>,
    val events: List<EventsTable>
)
