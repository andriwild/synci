package ch.boosters.backend.data.sport.model

import ch.boosters.data.tables.pojos.SportsTable
import java.util.*

/** Root of the Top Events page; listed before the sports. */
const val TOP_EVENTS = "TOP_EVENTS"

data class Sport(
    val id: UUID,
    val subSports: List<Sport>,
    val name: String,
    val label: String?,
    /** set when this node is an organisation or one of its groups */
    val organisationId: UUID? = null,
    /** teams play in this node or below it, e.g. to pick the teams of a Top Event */
    val hasTeams: Boolean = false,
)

/** Marks the nodes that have teams themselves or below them. */
fun Sport.withTeams(sportIdsWithTeams: Set<UUID>): Sport {
    val subSports = subSports.map { it.withTeams(sportIdsWithTeams) }
    return copy(subSports = subSports, hasTeams = id in sportIdsWithTeams || subSports.any { it.hasTeams })
}

fun Sport.flatten(): List<UUID> {
    val subSports =  this.subSports.flatMap { it.flatten() }
    return listOf<UUID>(id).plus(subSports)
}

fun SportsTable.toSport(subSports: List<Sport> = emptyList()) =
    Sport(id = id, subSports = subSports, name = name, label = label, organisationId = organisationId)
