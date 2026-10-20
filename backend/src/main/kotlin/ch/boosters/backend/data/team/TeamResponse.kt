package ch.boosters.backend.data.team

import ch.boosters.data.tables.pojos.TeamsTable
import ch.boosters.data.enums.GenderType

/** A team as returned to clients: the stored team plus a srcset for its logo, if the source has several sizes. */
data class TeamResponse(
    val id: String,
    val sourceId: Int,
    val name: String,
    val gender: GenderType?,
    val logoUrl: String?,
    val logoSrcSet: String?,
) {
    companion object {
        fun of(team: TeamsTable) = TeamResponse(
            id = team.id,
            sourceId = team.sourceId,
            name = team.name,
            gender = team.gender,
            logoUrl = team.logoUrl,
            logoSrcSet = TeamLogos.srcSet(team.logoUrl),
        )
    }
}
