package ch.boosters.backend.data.sport.business

import ch.boosters.backend.data.sport.model.Sport
import ch.boosters.data.tables.pojos.SportsTable
import java.util.UUID

fun List<SportsTable>.findSportsByParent(parentUUID: UUID?): Sport? {
    val elements = this
    val parent = elements.find { it.id == parentUUID }
    if (parent == null) return null

    val grouped = elements.groupBy { it.parentId }
    return Sport(
        id = parent.id,
        name = parent.name,
        label = parent.label,
        subSports = grouped[parent.id]
            ?.mapNotNull { s -> findSportsByParent(s.id) }
            ?: emptyList()
    )
}

fun List<SportsTable>.groupByRootSports(): List<Sport> {
    val grouped = this.groupBy { it.parentId}

    fun findAllSportsByParent(parentId: UUID?): List<Sport> {
        return grouped[parentId]?.map { record ->
            Sport(
                id = record.id,
                name = record.name,
                label = record.label,
                subSports = findAllSportsByParent(record.id)
            )
        } ?: emptyList()
    }
    return findAllSportsByParent(null)
}