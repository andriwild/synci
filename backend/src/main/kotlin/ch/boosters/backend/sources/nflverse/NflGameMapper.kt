package ch.boosters.backend.sources.nflverse

import ch.boosters.backend.data.event.model.TeamEvent
import ch.boosters.backend.data.team.Gender
import ch.boosters.backend.data.team.Team
import ch.boosters.backend.sources.nflverse.model.NflGame
import java.time.ZoneId
import java.time.ZonedDateTime

/** Pure mapping from nflverse rows to Synci events and teams. */
object NflGameMapper {

    /** sports_table.name column has 100 characters */
    const val MAX_EVENT_NAME_LENGTH = 100

    fun currentSeason(games: List<NflGame>, config: NflverseConfig): Int? =
        config.season ?: games.maxOfOrNull { it.season }

    /**
     * Kickoff converted from the source timezone (US Eastern) to the target timezone (Swiss local time).
     * Returns null while the kickoff time is not fixed yet.
     */
    fun toTeamEvent(game: NflGame, config: NflverseConfig): TeamEvent? {
        val time = game.gametime ?: return null
        val start = ZonedDateTime.of(game.gameday, time, ZoneId.of(config.sourceTimezone))
            .withZoneSameInstant(ZoneId.of(config.targetTimezone))
            .toLocalDateTime()
        return TeamEvent(
            id = game.gameId,
            startsOn = start,
            endsOn = start.plusMinutes(config.gameDurationMinutes),
            homeId = game.homeTeam,
            homeName = config.teamName(game.homeTeam),
            awayId = game.awayTeam,
            awayName = config.teamName(game.awayTeam),
            gender = Gender.MAN,
        )
    }

    /** "Home - Away", with the stadium appended for neutral-site games; falls back to abbreviations when too long. */
    fun eventName(game: NflGame, config: NflverseConfig): String {
        val suffix = if (game.isNeutralSite && !game.stadium.isNullOrBlank()) " (${game.stadium})" else ""
        val full = "${config.teamName(game.homeTeam)} - ${config.teamName(game.awayTeam)}$suffix"
        if (full.length <= MAX_EVENT_NAME_LENGTH) return full
        val short = "${game.homeTeam} - ${game.awayTeam}$suffix"
        return short.take(MAX_EVENT_NAME_LENGTH)
    }

    /** Every team that appears as home or away team, once; [logos] maps the abbreviation to its logo. */
    fun teamsOf(events: List<TeamEvent>, sourceId: Int, logos: Map<String, String> = emptyMap()): List<Team> =
        events.flatMap { listOf(it.homeId to it.homeName, it.awayId to it.awayName) }
            .distinctBy { it.first }
            .map { (id, name) -> Team(id, sourceId, name, Gender.MAN, logos[id.uppercase()]) }
}
