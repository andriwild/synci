package ch.boosters.backend.data.sport

import ch.boosters.backend.data.sport.business.findSportsByParent
import ch.boosters.data.tables.pojos.SportsTable
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import java.util.UUID

class SportDomainTest {

    @Test
    fun findSportsByParent() {
        // Given
        val sport1 = SportsTable(UUID.randomUUID(), "root", null)
        val sport2 = SportsTable(UUID.randomUUID(), "root2", null)
        val sport3 = SportsTable(UUID.randomUUID(), "root->1", sport1.id)
        val sport4 = SportsTable(UUID.randomUUID(), "root->2", sport1.id)
        val sport5 = SportsTable(UUID.randomUUID(), "root->2->1", sport4.id)
        val allSports = listOf(sport1, sport2, sport3, sport4, sport5)

        // When
        val grouped = allSports.findSportsByParent(sport1.id)

        // Then
        assertEquals(grouped?.subSports?.size, 2)
        assertEquals(grouped?.subSports?.map { it.id }?.sorted(), listOf(sport3.id, sport4.id).sorted()  )
    }

}