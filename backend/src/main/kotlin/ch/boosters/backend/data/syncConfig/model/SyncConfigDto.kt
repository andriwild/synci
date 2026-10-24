package ch.boosters.backend.data.syncConfig.model

import java.util.UUID

data class SyncConfigDto(
    val id: UUID?,
    val name: String?,
    val events: List<EventDto>,
    val teams: List<TeamDto>,
    /** sports, including organisations and their groups */
    val sports: List<UUID>,
    /**
     * Top Events; null keeps the stored ones, so app versions that do not know them cannot wipe them.
     * A new Abo sent without them starts with El Clásico.
     */
    val matchups: List<MatchupDto>? = null,
)

data class TeamDto(val id: String, val sourceId: Int)
data class EventDto(val id: String, val sourceId: Int)
data class MatchupDto(val sourceId: Int, val teamAId: String, val teamBId: String)
