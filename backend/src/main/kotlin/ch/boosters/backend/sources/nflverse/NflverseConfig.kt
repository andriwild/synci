package ch.boosters.backend.sources.nflverse

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.context.annotation.Configuration

/** Bound from sources/nflverse.yml */
@ConfigurationProperties(prefix = "nflverse")
@Configuration
class NflverseConfig {
    var name: String? = null
    var url: String? = null
    var fallbackUrls: MutableList<String> = mutableListOf()
    /** teams_colors_logos.csv; optional, without it teams have no logo */
    var teamsUrl: String? = null
    /** null = newest season in the file */
    var season: Int? = null
    var sourceTimezone: String = "America/New_York"
    var targetTimezone: String = "Europe/Zurich"
    var gameDurationMinutes: Long = 195
    /** game_type (lower case) -> sports_table.name */
    var gameTypes: MutableMap<String, String> = mutableMapOf()
    /** team abbreviation (lower case) -> display name */
    var teams: MutableMap<String, String> = mutableMapOf()

    fun sportKeyFor(gameType: String): String? = gameTypes[gameType.lowercase()]

    fun teamName(abbreviation: String): String = teams[abbreviation.lowercase()] ?: abbreviation
}
