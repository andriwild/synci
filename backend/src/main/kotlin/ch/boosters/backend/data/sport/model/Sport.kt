package ch.boosters.backend.data.sport.model

import ch.boosters.data.tables.pojos.SportsTable
import java.util.*

data class Sport(
    val id: UUID,
    val subSports: List<Sport>,
    val name: String,
    val label: String?,
    /** set when this node is an organisation or one of its groups */
    val organisationId: UUID? = null
)

fun Sport.flatten(): List<UUID> {
    val subSports =  this.subSports.flatMap { it.flatten() }
    return listOf<UUID>(id).plus(subSports)
}

fun SportsTable.toSport(subSports: List<Sport> = emptyList()) =
    Sport(id = id, subSports = subSports, name = name, label = label, organisationId = organisationId)
