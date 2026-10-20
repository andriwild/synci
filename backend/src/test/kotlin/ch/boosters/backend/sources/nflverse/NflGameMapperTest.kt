package ch.boosters.backend.sources.nflverse

import ch.boosters.backend.data.team.Gender
import ch.boosters.backend.sources.nflverse.model.NflGame
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Test
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime

class NflGameMapperTest {

    private val config = NflverseConfig().apply {
        gameTypes = mutableMapOf("reg" to "NFL_REGULAR_SEASON", "sb" to "NFL_PLAYOFFS")
        teams = mutableMapOf(
            "ne" to "New England Patriots",
            "chi" to "Chicago Bears",
            "pit" to "Pittsburgh Steelers",
            "no" to "New Orleans Saints",
        )
    }

    private fun game(
        id: String = "2026_07_NE_CHI",
        season: Int = 2026,
        type: String = "REG",
        day: LocalDate = LocalDate.of(2026, 10, 22),
        time: LocalTime? = LocalTime.of(20, 15),
        away: String = "NE",
        home: String = "CHI",
        location: String = "Home",
        stadium: String? = "Soldier Field",
    ) = NflGame(id, season, type, 7, day, time, away, home, location, stadium)

    @Test
    fun `converts eastern daylight time to swiss summer time`() {
        val event = NflGameMapper.toTeamEvent(game(), config)!!
        // 22.10. 20:15 EDT = 23.10. 00:15 UTC = 02:15 CEST
        assertEquals(LocalDateTime.of(2026, 10, 23, 2, 15), event.startsOn)
        assertEquals(LocalDateTime.of(2026, 10, 23, 5, 30), event.endsOn)
    }

    @Test
    fun `converts eastern standard time to swiss winter time`() {
        // US switches on 1.11.2026, Europe on 25.10.2026: 13:00 EST = 18:00 UTC = 19:00 CET
        val event = NflGameMapper.toTeamEvent(game(day = LocalDate.of(2026, 11, 1), time = LocalTime.of(13, 0)), config)!!
        assertEquals(LocalDateTime.of(2026, 11, 1, 19, 0), event.startsOn)
    }

    @Test
    fun `game without kickoff time is skipped`() {
        assertNull(NflGameMapper.toTeamEvent(game(time = null), config))
    }

    @Test
    fun `event carries team ids names and gender`() {
        val event = NflGameMapper.toTeamEvent(game(), config)!!
        assertEquals("2026_07_NE_CHI", event.id)
        assertEquals("CHI", event.homeId)
        assertEquals("Chicago Bears", event.homeName)
        assertEquals("NE", event.awayId)
        assertEquals("New England Patriots", event.awayName)
        assertEquals(Gender.MAN, event.gender)
    }

    @Test
    fun `unknown abbreviation falls back to the abbreviation`() {
        val event = NflGameMapper.toTeamEvent(game(home = "XYZ"), config)!!
        assertEquals("XYZ", event.homeName)
    }

    @Test
    fun `maps game types to sport keys`() {
        assertEquals("NFL_REGULAR_SEASON", config.sportKeyFor("REG"))
        assertEquals("NFL_PLAYOFFS", config.sportKeyFor("SB"))
        assertNull(config.sportKeyFor("PRE"))
    }

    @Test
    fun `event name is home dash away with stadium for neutral sites`() {
        assertEquals("Chicago Bears - New England Patriots", NflGameMapper.eventName(game(), config))
        val neutral = game(id = "2026_07_PIT_NO", away = "PIT", home = "NO", location = "Neutral", stadium = "Stade de France")
        assertEquals("New Orleans Saints - Pittsburgh Steelers (Stade de France)", NflGameMapper.eventName(neutral, config))
    }

    @Test
    fun `event name longer than 100 characters falls back to abbreviations`() {
        val longNames = NflverseConfig().apply {
            teams = mutableMapOf("ne" to "N".repeat(60), "chi" to "C".repeat(60))
        }
        val name = NflGameMapper.eventName(game(), longNames)
        assertEquals("CHI - NE", name)
    }

    @Test
    fun `current season is the newest in the file unless configured`() {
        val games = listOf(game(season = 2025), game(season = 2026), game(season = 2024))
        assertEquals(2026, NflGameMapper.currentSeason(games, config))
        assertEquals(2024, NflGameMapper.currentSeason(games, NflverseConfig().apply { season = 2024 }))
        assertNull(NflGameMapper.currentSeason(emptyList(), config))
    }

    @Test
    fun `teams are collected once from both sides`() {
        val events = listOfNotNull(
            NflGameMapper.toTeamEvent(game(), config),
            NflGameMapper.toTeamEvent(game(id = "2026_08_CHI_NE", away = "CHI", home = "NE"), config),
        )
        val teams = NflGameMapper.teamsOf(events, 7)
        assertEquals(listOf("CHI", "NE"), teams.map { it.id }.sorted())
        assertEquals(7, teams.first().source)
    }

    @Test
    fun `teams get their logo by abbreviation, unknown ones none`() {
        val events = listOfNotNull(NflGameMapper.toTeamEvent(game(), config))
        val logos = NflGameMapper.teamsOf(events, 7, mapOf("CHI" to "https://a.espncdn.com/i/teamlogos/nfl/500/chi.png"))
            .associate { it.id to it.logoUrl }
        assertEquals("https://a.espncdn.com/i/teamlogos/nfl/500/chi.png", logos["CHI"])
        assertNull(logos["NE"])
    }
}
