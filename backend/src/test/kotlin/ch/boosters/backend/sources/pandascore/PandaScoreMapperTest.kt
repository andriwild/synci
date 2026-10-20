package ch.boosters.backend.sources.pandascore

import ch.boosters.backend.sources.pandascore.model.PandaScoreLeague
import ch.boosters.backend.sources.pandascore.model.PandaScoreMatch
import ch.boosters.backend.sources.pandascore.model.PandaScoreOpponent
import ch.boosters.backend.sources.pandascore.model.PandaScoreTeam
import ch.boosters.backend.sources.pandascore.model.PandaScoreTournament
import kotlinx.serialization.json.Json
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertInstanceOf
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import java.time.LocalDateTime

class PandaScoreMapperTest {

    private val json = Json { ignoreUnknownKeys = true }
    private val matches: List<PandaScoreMatch> = json.decodeFromString(
        javaClass.getResource("/pandascore/matches_upcoming_lol.json")!!.readText()
    )
    private val config = PandaScoreConfig()
    private val lol = PandaScoreGame().apply { slug = "league-of-legends"; sport = "ESPORTS_LOL"; minutesPerGame = 40 }

    private fun match(id: Long) = matches.first { it.id == id }

    @Test
    fun `parses the documented match fields and ignores unknown ones`() {
        assertEquals(5, matches.size)
        val first = match(1210001)
        assertEquals("Worlds", first.league.name)
        assertEquals("s", first.tournament?.tier)
        assertEquals(listOf("C9", "KC"), first.opponents.map { it.opponent.acronym })
    }

    @Test
    fun `converts UTC to Swiss summer and winter time`() {
        assertEquals(LocalDateTime.of(2026, 10, 15, 20, 0), PandaScoreMapper.startsOn(match(1210001), config))
        // after the switch to CET on 25.10.2026: 18:00Z = 19:00
        assertEquals(LocalDateTime.of(2026, 11, 1, 19, 0), PandaScoreMapper.startsOn(match(1210003), config))
    }

    @Test
    fun `match with both teams becomes a team event with duration per game`() {
        val mapped = PandaScoreMapper.map(match(1210001), lol, config)
        assertInstanceOf(MappedMatch.WithTeams::class.java, mapped)
        mapped as MappedMatch.WithTeams
        assertEquals("ESPORTS_LEAGUE_297", mapped.leagueNode)
        assertEquals("Worlds: Cloud9 - Karmine Corp", mapped.name)
        assertEquals("1097", mapped.event.homeId)
        assertEquals("128268", mapped.event.awayId)
        // best of 5 x 40 minutes
        assertEquals(LocalDateTime.of(2026, 10, 15, 23, 20), mapped.event.endsOn)
    }

    @Test
    fun `match without opponents keeps its name and has no teams`() {
        val mapped = PandaScoreMapper.map(match(1210002), lol, config)
        assertInstanceOf(MappedMatch.WithoutTeams::class.java, mapped)
        assertEquals("Worlds: Swiss stage: TBD vs TBD", (mapped as MappedMatch.WithoutTeams).event.name)
    }

    @Test
    fun `canceled and unscheduled matches are not mapped`() {
        assertTrue(PandaScoreMapper.isCanceled(match(1210004)))
        assertNull(PandaScoreMapper.map(match(1210004), lol, config))
        assertNull(PandaScoreMapper.map(match(1210005), lol, config))
    }

    @Test
    fun `only configured tournament tiers are relevant`() {
        assertTrue(PandaScoreMapper.isRelevant(match(1210001), lol, config))
        assertFalse(PandaScoreMapper.isRelevant(match(1210003), lol, config))
    }

    @Test
    fun `game tiers override the default tiers`() {
        val withC = PandaScoreGame().apply { slug = "league-of-legends"; sport = "ESPORTS_LOL"; tiers = mutableListOf("s", "c") }
        assertTrue(PandaScoreMapper.isRelevant(match(1210003), withC, config))
        val onlyA = PandaScoreGame().apply { slug = "league-of-legends"; sport = "ESPORTS_LOL"; tiers = mutableListOf("a") }
        assertFalse(PandaScoreMapper.isRelevant(match(1210001), onlyA, config))
    }

    @Test
    fun `included leagues are shown regardless of tier`() {
        val game = PandaScoreGame().apply {
            slug = "league-of-legends"; sport = "ESPORTS_LOL"; includeLeagues = mutableListOf("small-league")
        }
        assertTrue(PandaScoreMapper.isRelevant(match(1210003), game, config))
    }

    @Test
    fun `long names fall back to acronyms and are cut at 100 characters`() {
        val long = PandaScoreMatch(
            id = 1, scheduledAt = "2026-10-15T18:00:00Z", numberOfGames = 1,
            league = PandaScoreLeague(1, "L".repeat(30)),
            tournament = PandaScoreTournament(tier = "s"),
            opponents = listOf(
                PandaScoreOpponent("Team", PandaScoreTeam(1, "A".repeat(50), "AAA")),
                PandaScoreOpponent("Team", PandaScoreTeam(2, "B".repeat(50), "BBB")),
            ),
        )
        assertEquals("${"L".repeat(30)}: AAA - BBB", PandaScoreMapper.eventName(long))
        assertTrue(PandaScoreMapper.eventName(long.copy(opponents = emptyList(), name = "N".repeat(200))).length <= 100)
    }

    @Test
    fun `teams are collected once from both sides`() {
        val events = listOf(match(1210001), match(1210003))
            .mapNotNull { PandaScoreMapper.map(it, lol, config) as? MappedMatch.WithTeams }
            .map { it.event }
        val teams = PandaScoreMapper.teamsOf(events, matches, 9)
        assertEquals(listOf("1", "1097", "128268", "2"), teams.map { it.id }.sorted())
        assertEquals(9, teams.first().source)
    }

    @Test
    fun `teams carry their logo when PandaScore has one`() {
        val events = listOf(match(1210001))
            .mapNotNull { PandaScoreMapper.map(it, lol, config) as? MappedMatch.WithTeams }
            .map { it.event }
        val logos = PandaScoreMapper.teamsOf(events, matches, 9).associate { it.name to it.logoUrl }
        assertEquals("https://cdn.pandascore.co/images/team/image/1097/cloud9.png", logos["Cloud9"])
        assertNull(logos["Karmine Corp"])
    }
}
