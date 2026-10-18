package ch.boosters.backend.sources.cfbd

import ch.boosters.backend.sources.cfbd.model.CfbdGame
import kotlinx.serialization.json.Json
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import java.time.LocalDate
import java.time.LocalDateTime

class CfbdGameMapperTest {

    private val json = Json { ignoreUnknownKeys = true }
    private val games: List<CfbdGame> = json.decodeFromString(
        javaClass.getResource("/cfbd/games_fbs.json")!!.readText()
    )
    private val config = CfbdConfig()

    private fun game(id: Long) = games.first { it.id == id }

    @Test
    fun `parses the documented game fields and ignores unknown ones`() {
        assertEquals(6, games.size)
        val first = game(401754601)
        assertEquals("Alabama", first.homeTeam)
        assertEquals("SEC", first.awayConference)
        assertNull(game(401754602).homeConference)
    }

    @Test
    fun `converts UTC to Swiss summer and winter time`() {
        assertEquals(LocalDateTime.of(2026, 10, 17, 21, 30), CfbdGameMapper.startsOn(game(401754601), config))
        // after the switch to CET on 25.10.2026: 17:00Z = 18:00
        assertEquals(LocalDateTime.of(2026, 11, 7, 18, 0), CfbdGameMapper.startsOn(game(401754602), config))
    }

    @Test
    fun `games without kickoff time and finished games are skipped`() {
        assertNull(CfbdGameMapper.map(game(401754603), config))
        assertNull(CfbdGameMapper.map(game(401754606), config))
    }

    @Test
    fun `regular games go to the conference of the home team, independents and FCS hosts are handled`() {
        assertEquals("NCAA_CONF_SEC", CfbdGameMapper.map(game(401754601), config)?.sportNode)
        assertEquals("NCAA_CONF_FBS_INDEPENDENTS", CfbdGameMapper.map(game(401754602), config)?.sportNode)
        // FCS home team: the game belongs to the conference of the FBS visitor
        assertEquals("NCAA_CONF_SEC", CfbdGameMapper.map(game(401754604), config)?.sportNode)
    }

    @Test
    fun `postseason games go to the bowls node and carry the bowl name`() {
        val bowl = CfbdGameMapper.map(game(401754605), config)!!
        assertEquals(CfbdGameMapper.POSTSEASON_NODE, bowl.sportNode)
        assertEquals("Rose Bowl Game presented by Prudential: Ohio State - Oregon", bowl.name)
        assertEquals(bowl.event.startsOn.plusMinutes(210), bowl.event.endsOn)
    }

    @Test
    fun `regular game names are home - away and never longer than 100 characters`() {
        assertEquals("Alabama - Georgia", CfbdGameMapper.eventName(game(401754601)))
        val long = game(401754605).copy(notes = "x".repeat(120))
        assertEquals("Ohio State - Oregon", CfbdGameMapper.eventName(long))
        assertTrue(CfbdGameMapper.eventName(long.copy(homeTeam = "y".repeat(120))).length <= CfbdGameMapper.MAX_EVENT_NAME_LENGTH)
    }

    @Test
    fun `conferences and team links only contain teams of the configured classification`() {
        assertEquals(
            mapOf("NCAA_CONF_SEC" to "SEC", "NCAA_CONF_FBS_INDEPENDENTS" to "FBS Independents", "NCAA_CONF_BIG_TEN" to "Big Ten"),
            CfbdGameMapper.conferences(games, config),
        )
        val teams = CfbdGameMapper.teamsByConference(games, 7, config)
        assertEquals(setOf("Alabama", "Georgia", "Tennessee"), teams.getValue("NCAA_CONF_SEC").map { it.name }.toSet())
        assertTrue(teams.values.flatten().none { it.name == "Sam Houston" })
    }

    @Test
    fun `season defaults to the current year, in January to the previous one`() {
        assertEquals(2026, CfbdGameMapper.season(config, LocalDate.of(2026, 10, 18)))
        assertEquals(2026, CfbdGameMapper.season(config, LocalDate.of(2027, 1, 10)))
        assertEquals(2025, CfbdGameMapper.season(CfbdConfig().apply { season = 2025 }, LocalDate.of(2026, 10, 18)))
    }
}
