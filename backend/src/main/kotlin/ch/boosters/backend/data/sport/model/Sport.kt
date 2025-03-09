package ch.boosters.backend.data.sport.model

import java.util.*

data class Sport(
    val id: UUID,
    val subSports: List<Sport>,
    val name: String
)

fun Sport.flatten(): List<UUID> {
    val subSports =  this.subSports.flatMap { it.flatten() }
    return listOf<UUID>(id).plus(subSports)
}