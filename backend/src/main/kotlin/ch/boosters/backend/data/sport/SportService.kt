package ch.boosters.backend.data.sport

import ch.boosters.data.tables.pojos.SportsTable
import org.springframework.stereotype.Service
import java.util.UUID

@Service
class SportService(
    private val sportRepository: SportRepository
) {
    fun getSports(): List<Sport> {
        val sports: List<SportsTable> = sportRepository.allSports()
        val grouped = sports.groupBy { it.parentId}

        fun buildTree(parentId: UUID?): List<Sport> {
            return grouped[parentId]?.map { record ->
                Sport(
                    id = record.id,
                    name = record.name,
                    subSports = buildTree(record.id)
                )
            } ?: emptyList()
        }

        // start with all entries which have no parent (parent is null)
        return buildTree(null)
    }
}
