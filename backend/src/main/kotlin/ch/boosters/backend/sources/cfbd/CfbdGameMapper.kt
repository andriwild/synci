package ch.boosters.backend.sources.cfbd

import ch.boosters.backend.data.event.model.TeamEvent
import ch.boosters.backend.data.team.Gender
import ch.boosters.backend.data.team.Team
import ch.boosters.backend.sources.cfbd.model.CfbdGame
import java.time.Instant
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.Month
import java.time.ZoneId

/** A game ready to be stored below the sport node [sportNode]. */
data class MappedGame(val sportNode: String, val event: TeamEvent, val name: String)

/** Pure mapping from CollegeFootballData games to Synci nodes, events and teams. */
object CfbdGameMapper {

    /** events_table.name has 100 characters */
    const val MAX_EVENT_NAME_LENGTH = 100

    const val POSTSEASON_NODE = "NCAA_POSTSEASON"
    const val CONFERENCE_PARENT_NODE = "NCAA_FOOTBALL"
    private const val INDEPENDENTS = "FBS Independents"

    /** The configured season, otherwise the current year; in January still the previous one (bowls, playoff final). */
    fun season(config: CfbdConfig, today: LocalDate = LocalDate.now()): Int =
        config.season ?: if (today.month == Month.JANUARY) today.year - 1 else today.year

    /** "Big Ten" -> NCAA_CONF_BIG_TEN */
    fun conferenceNodeName(conference: String) =
        "NCAA_CONF_" + conference.uppercase().replace(Regex("[^A-Z0-9]+"), "_").trim('_')

    /** Conference of a team, null for teams outside the configured classification (e.g. FCS opponents). */
    fun conferenceOf(conference: String?, classification: String?, config: CfbdConfig): String? =
        if (classification != null && !classification.equals(config.classification, ignoreCase = true)) null
        else conference ?: INDEPENDENTS

    /**
     * Postseason games go to the bowls node, regular games to the conference of the home team, or of the
     * away team when the home team is outside the configured classification.
     */
    fun sportNode(game: CfbdGame, config: CfbdConfig): String? {
        if (game.seasonType.equals("postseason", ignoreCase = true)) return POSTSEASON_NODE
        val conference = conferenceOf(game.homeConference, game.homeClassification, config)
            ?: conferenceOf(game.awayConference, game.awayClassification, config)
        return conference?.let(::conferenceNodeName)
    }

    /** Every conference of the configured classification that appears in [games], keyed by node name. */
    fun conferences(games: List<CfbdGame>, config: CfbdConfig): Map<String, String> =
        games.flatMap {
            listOfNotNull(
                conferenceOf(it.homeConference, it.homeClassification, config),
                conferenceOf(it.awayConference, it.awayClassification, config),
            )
        }.distinct().associateBy(::conferenceNodeName)

    fun startsOn(game: CfbdGame, config: CfbdConfig): LocalDateTime =
        Instant.parse(game.startDate).atZone(ZoneId.of(config.timezone)).toLocalDateTime()

    /** "Alabama - Georgia", for bowls "Rose Bowl: Ohio State - Oregon". */
    fun eventName(game: CfbdGame): String {
        val teams = "${game.homeTeam} - ${game.awayTeam}"
        val prefix = game.notes?.takeIf { game.seasonType.equals("postseason", ignoreCase = true) && it.isNotBlank() }
        val full = if (prefix != null) "$prefix: $teams" else teams
        return if (full.length <= MAX_EVENT_NAME_LENGTH) full else teams.take(MAX_EVENT_NAME_LENGTH)
    }

    /** Returns null for games that cannot be placed in a calendar yet (kickoff time not announced) or are over. */
    fun map(game: CfbdGame, config: CfbdConfig): MappedGame? {
        if (game.startTimeTBD || game.completed) return null
        val node = sportNode(game, config) ?: return null
        val start = startsOn(game, config)
        val event = TeamEvent(
            id = game.id.toString(),
            startsOn = start,
            endsOn = start.plusMinutes(config.gameDurationMinutes),
            homeId = game.homeId.toString(),
            homeName = game.homeTeam,
            awayId = game.awayId.toString(),
            awayName = game.awayTeam,
            gender = Gender.MAN,
        )
        return MappedGame(node, event, eventName(game))
    }

    /** Teams of the configured classification grouped by their conference node. */
    fun teamsByConference(games: List<CfbdGame>, sourceId: Int, config: CfbdConfig): Map<String, List<Team>> =
        games.flatMap {
            listOf(
                Triple(it.homeId, it.homeTeam, conferenceOf(it.homeConference, it.homeClassification, config)),
                Triple(it.awayId, it.awayTeam, conferenceOf(it.awayConference, it.awayClassification, config)),
            )
        }
            .filter { it.third != null }
            .distinctBy { it.first }
            .groupBy({ conferenceNodeName(it.third!!) }, { Team(it.first.toString(), sourceId, it.second, Gender.MAN) })

    fun teamsOf(events: List<TeamEvent>, sourceId: Int): List<Team> =
        events.flatMap { listOf(it.homeId to it.homeName, it.awayId to it.awayName) }
            .distinctBy { it.first }
            .map { (id, name) -> Team(id, sourceId, name, Gender.MAN) }
}
