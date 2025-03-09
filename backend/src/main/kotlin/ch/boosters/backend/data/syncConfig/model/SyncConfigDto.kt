package ch.boosters.backend.data.syncConfig.model

import java.util.UUID

data class SyncConfigDto(
    val id: UUID?,
    val name: String?,
    val events: List<EventDto>,
    val teams: List<TeamDto>,
    val sports: List<UUID>
)

data class TeamDto(val id: String, val sourceId: Int)
data class EventDto(val id: String, val sourceId: Int)
