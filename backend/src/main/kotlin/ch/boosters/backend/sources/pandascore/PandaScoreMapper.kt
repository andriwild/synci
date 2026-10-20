package ch.boosters.backend.sources.pandascore

import ch.boosters.backend.data.event.model.Event
import ch.boosters.backend.data.event.model.TeamEvent
import ch.boosters.backend.data.team.Gender
import ch.boosters.backend.data.team.Team
import ch.boosters.backend.sources.pandascore.model.PandaScoreLeague
import ch.boosters.backend.sources.pandascore.model.PandaScoreMatch
import java.time.Instant
import java.time.LocalDateTime
import java.time.ZoneId

/** A match ready to be stored: with both teams known it becomes a team event, otherwise a plain event. */
sealed interface MappedMatch {
    val leagueNode: String
    data class WithTeams(override val leagueNode: String, val event: TeamEvent, val name: String) : MappedMatch
    data class WithoutTeams(override val leagueNode: String, val event: Event) : MappedMatch
}

/** Pure mapping from PandaScore matches to Synci nodes, events and teams. */
object PandaScoreMapper {

    /** events_table.name has 100 characters */
    const val MAX_EVENT_NAME_LENGTH = 100

    private val CANCELED = setOf("canceled")
    private val NOT_PLANNABLE = setOf("postponed")

    fun leagueNodeName(league: PandaScoreLeague) = "ESPORTS_LEAGUE_${league.id}"

    fun isCanceled(match: PandaScoreMatch) = match.status in CANCELED

    /**
     * A match is shown when its league is explicitly included for the game, or its tournament tier is
     * in the game's tiers (falling back to the default tiers). Matches without tier count as unranked.
     */
    fun isRelevant(match: PandaScoreMatch, game: PandaScoreGame, config: PandaScoreConfig): Boolean {
        val slug = match.league.slug?.lowercase()
        if (slug != null && game.includeLeagues.any { it.lowercase() == slug }) return true
        val tier = (match.tournament?.tier ?: "unranked").lowercase()
        return (game.tiers ?: config.tiers).any { it.lowercase() == tier }
    }

    fun startsOn(match: PandaScoreMatch, config: PandaScoreConfig): LocalDateTime? =
        match.scheduledAt?.let { Instant.parse(it).atZone(ZoneId.of(config.timezone)).toLocalDateTime() }

    /** "LEC: G2 Esports - Fnatic", or "Worlds: <match name>" while opponents are unknown. */
    fun eventName(match: PandaScoreMatch): String {
        val teams = teamOpponents(match)
        val body = if (teams.size == 2) "${teams[0].name} - ${teams[1].name}" else match.name ?: "TBD"
        val full = "${match.league.name}: $body"
        if (full.length <= MAX_EVENT_NAME_LENGTH) return full
        val short = if (teams.size == 2) "${match.league.name}: ${teams[0].acronym ?: teams[0].name} - ${teams[1].acronym ?: teams[1].name}" else full
        return short.take(MAX_EVENT_NAME_LENGTH)
    }

    /**
     * Returns null for matches that cannot be placed in a calendar (no date, postponed without
     * a new date). Duration = number of games × configured minutes per game.
     */
    fun map(match: PandaScoreMatch, game: PandaScoreGame, config: PandaScoreConfig): MappedMatch? {
        if (match.status in NOT_PLANNABLE || isCanceled(match)) return null
        val start = startsOn(match, config) ?: return null
        val end = start.plusMinutes(maxOf(1, match.numberOfGames ?: 1) * game.minutesPerGame)
        val id = match.id.toString()
        val node = leagueNodeName(match.league)
        val teams = teamOpponents(match)
        return if (teams.size == 2) {
            MappedMatch.WithTeams(
                leagueNode = node,
                event = TeamEvent(
                    id = id,
                    startsOn = start,
                    endsOn = end,
                    homeId = teams[0].id.toString(),
                    homeName = teams[0].name,
                    awayId = teams[1].id.toString(),
                    awayName = teams[1].name,
                    gender = Gender.UNKNOWN,
                ),
                name = eventName(match),
            )
        } else {
            MappedMatch.WithoutTeams(node, Event(id, eventName(match), start, end))
        }
    }

    /** Teams of [events]; their logos come from the opponents in [matches]. */
    fun teamsOf(events: List<TeamEvent>, matches: List<PandaScoreMatch>, sourceId: Int): List<Team> {
        val logos = matches.flatMap(::teamOpponents).filter { it.imageUrl != null }.associate { it.id.toString() to it.imageUrl }
        return events.flatMap { listOf(it.homeId to it.homeName, it.awayId to it.awayName) }
            .distinctBy { it.first }
            .map { (id, name) -> Team(id, sourceId, name, Gender.UNKNOWN, logos[id]) }
    }

    private fun teamOpponents(match: PandaScoreMatch) =
        match.opponents.filter { it.type == null || it.type == "Team" }.map { it.opponent }
}
