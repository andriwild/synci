package ch.boosters.backend.data.syncConfig.syncConfigMatchups

import ch.boosters.backend.data.syncConfig.model.MatchupDto
import ch.boosters.backend.errorhandling.InvalidRequest
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertInstanceOf
import org.junit.jupiter.api.Test

class MatchupsTest {

    private fun matchup(a: String, b: String) = MatchupDto(3, a, b)

    @Test
    fun `keeps the order of the list and of the teams`() {
        val matchups = listOf(matchup("5477", "5469"), matchup("2", "8"))

        assertEquals(matchups, normalizeMatchups(matchups).getOrNull())
    }

    @Test
    fun `drops a repeat with swapped teams`() {
        val normalized = normalizeMatchups(listOf(matchup("5477", "5469"), matchup("5469", "5477"), matchup("5477", "5469")))

        assertEquals(listOf(matchup("5477", "5469")), normalized.getOrNull())
    }

    @Test
    fun `keeps the same teams of another source apart`() {
        val matchups = listOf(matchup("1", "2"), MatchupDto(4, "1", "2"))

        assertEquals(matchups, normalizeMatchups(matchups).getOrNull())
    }

    @Test
    fun `rejects a team against itself`() {
        assertInstanceOf(InvalidRequest::class.java, normalizeMatchups(listOf(matchup("1", "1"))).leftOrNull())
    }

    @Test
    fun `allows up to the limit`() {
        val atLimit = List(MATCHUP_LIMIT) { matchup("a$it", "b$it") }

        assertEquals(atLimit, normalizeMatchups(atLimit).getOrNull())
        assertInstanceOf(InvalidRequest::class.java, normalizeMatchups(atLimit + matchup("x", "y")).leftOrNull())
    }
}
