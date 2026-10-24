package ch.boosters.backend.data.sport

import ch.boosters.backend.data.sport.business.findSportsByParent
import ch.boosters.backend.data.sport.business.groupByRootSports
import ch.boosters.backend.data.sport.model.TOP_EVENTS
import ch.boosters.backend.data.sport.model.withTeams
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


    @Test
    fun topEventsLeadTheRootsInLabelOrder() {
        val roots = listOf(
            SportsTable(UUID.randomUUID(), "AMERICAN_FOOTBALL", null, "American Football"),
            SportsTable(UUID.randomUUID(), "SOCCER", null, "Fussball"),
            SportsTable(UUID.randomUUID(), TOP_EVENTS, null, "Top Events"),
            SportsTable(UUID.randomUUID(), "VOLLEYBALL", null, "Volleyball"),
        )

        val tree = roots.groupByRootSports()

        assertEquals(listOf(TOP_EVENTS, "AMERICAN_FOOTBALL", "SOCCER", "VOLLEYBALL"), tree.map { it.name })
    }

    @Test
    fun marksNodesWithTeamsAndTheirParents() {
        val soccer = SportsTable(UUID.randomUUID(), "SOCCER", null, "Fussball")
        val league = SportsTable(UUID.randomUUID(), "SOCCER_SUPER_LEAGUE", soccer.id, "Super League")
        val ski = SportsTable(UUID.randomUUID(), "SKI_ALPINE", null, "Ski Alpin")

        val tree = listOf(soccer, league, ski).groupByRootSports().map { it.withTeams(setOf(league.id)) }

        assertEquals(listOf(true, false), tree.map { it.hasTeams })
        assertEquals(true, tree.first().subSports.single().hasTeams)
    }

    @Test
    fun organisationIdIsKeptInTheTree() {
        val organisationId = UUID.randomUUID()
        val root = SportsTable(UUID.randomUUID(), "ORG_x", null, "FC Test", organisationId)
        val group = SportsTable(UUID.randomUUID(), "GRP_y", root.id, "1. Mannschaft", organisationId)
        val publicSport = SportsTable(UUID.randomUUID(), "SOCCER", null, "Fussball", null)

        val tree = listOf(root, group, publicSport).findSportsByParent(root.id)

        assertEquals(organisationId, tree?.organisationId)
        assertEquals(listOf(organisationId), tree?.subSports?.map { it.organisationId })
        assertEquals("1. Mannschaft", tree?.subSports?.first()?.label)
    }
}
