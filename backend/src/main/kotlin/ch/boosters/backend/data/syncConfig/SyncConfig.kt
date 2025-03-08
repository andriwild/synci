package ch.boosters.backend.data.syncConfig

import ch.boosters.backend.data.sport.Sport
import ch.boosters.backend.data.team.Team
import ch.boosters.data.tables.pojos.SportsTable
import java.util.UUID

data class SyncConfig (
    val id: UUID?,
    val name: String,
    val teams: List<Team>,
    val sports: List<SportsTable>,
)
