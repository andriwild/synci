package ch.boosters.backend.data.syncConfig

import ch.boosters.backend.data.team.Team
import java.util.UUID

data class SyncConfig (
    val id: UUID,
    val url: String,
    val teams: List<Team>
)