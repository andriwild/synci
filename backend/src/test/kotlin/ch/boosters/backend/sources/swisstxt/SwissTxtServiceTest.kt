package ch.boosters.backend.sources.swisstxt

import ch.boosters.backend.data.event.model.TeamEvent
import ch.boosters.backend.data.team.Gender
import ch.boosters.backend.data.team.TeamLogos
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import java.time.LocalDateTime

class SwissTxtServiceTest {

    private fun game(homeId: String, awayId: String, startsOn: LocalDateTime = LocalDateTime.now().plusDays(1)) =
        TeamEvent("$homeId-$awayId", startsOn, startsOn.plusHours(2), homeId, "Team $homeId", awayId, "Team $awayId", Gender.MAN)

    @Test
    fun `takes home and away teams once`() {
        val teams = SwissTxtService.teamsOf(listOf(game("1", "2"), game("2", "3"), game("3", "1")), 3)

        assertEquals(listOf("1", "2", "3"), teams.map { it.id })
        assertEquals(listOf("Team 1", "Team 2", "Team 3"), teams.map { it.name })
        assertEquals(TeamLogos.swissTxtLogo("3"), teams.last().logoUrl)
        assertEquals(setOf(3), teams.map { it.source }.toSet())
    }

    @Test
    fun `keeps teams whose games are all played`() {
        val teams = SwissTxtService.teamsOf(listOf(game("1", "2", LocalDateTime.now().minusDays(30)), game("3", "4")), 3)

        assertEquals(listOf("1", "2", "3", "4"), teams.map { it.id })
    }

    @Test
    fun `skips opponents that are not known yet`() {
        val teams = SwissTxtService.teamsOf(listOf(game("1", ""), game("", "2")), 3)

        assertEquals(listOf("1", "2"), teams.map { it.id })
    }
}
