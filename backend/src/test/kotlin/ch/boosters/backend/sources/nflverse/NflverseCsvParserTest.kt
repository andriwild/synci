package ch.boosters.backend.sources.nflverse

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Test
import java.time.LocalDate
import java.time.LocalTime

class NflverseCsvParserTest {

    private val sample = javaClass.getResource("/nflverse/games_sample.csv")!!.readText()

    @Test
    fun `parses every data row`() {
        val games = NflverseCsvParser.parse(sample)
        assertEquals(6, games.size)
        assertEquals(listOf(2025, 2026, 2026, 2026, 2026, 2026), games.map { it.season })
    }

    @Test
    fun `reads the columns by header name`() {
        val game = NflverseCsvParser.parse(sample).first { it.gameId == "2026_07_NE_CHI" }
        assertEquals("REG", game.gameType)
        assertEquals(7, game.week)
        assertEquals(LocalDate.of(2026, 10, 22), game.gameday)
        assertEquals(LocalTime.of(20, 15), game.gametime)
        assertEquals("NE", game.awayTeam)
        assertEquals("CHI", game.homeTeam)
        assertEquals("Home", game.location)
        assertEquals("Soldier Field", game.stadium)
    }

    @Test
    fun `handles quoted empty fields and neutral sites`() {
        val game = NflverseCsvParser.parse(sample).first { it.gameId == "2026_07_PIT_NO" }
        assertEquals(true, game.isNeutralSite)
        assertEquals("Stade de France", game.stadium)
    }

    @Test
    fun `missing kickoff time becomes null`() {
        val game = NflverseCsvParser.parse(sample).first { it.gameId == "2026_18_NE_NYJ" }
        assertNull(game.gametime)
    }

    @Test
    fun `column order does not matter`() {
        val csv = """
            home_team,away_team,gametime,gameday,week,game_type,season,game_id,location,stadium
            CHI,NE,20:15,2026-10-22,7,REG,2026,2026_07_NE_CHI,Home,Soldier Field
        """.trimIndent()
        val game = NflverseCsvParser.parse(csv).single()
        assertEquals("2026_07_NE_CHI", game.gameId)
        assertEquals("CHI", game.homeTeam)
    }
}
