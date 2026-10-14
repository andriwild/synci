package ch.boosters.backend.sources.pandascore

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.context.annotation.Configuration

/** Bound from sources/pandascore.yml */
@ConfigurationProperties(prefix = "pandascore")
@Configuration
class PandaScoreConfig {
    var name: String? = null
    var url: String = "https://api.pandascore.co"
    var token: String? = null
    var pageSize: Int = 100
    /** tournament tiers whose leagues are shown in the tree */
    var tiers: MutableList<String> = mutableListOf("s", "a")
    var timezone: String = "Europe/Zurich"
    var games: MutableList<PandaScoreGame> = mutableListOf()
}

class PandaScoreGame {
    /** PandaScore videogame slug, e.g. league-of-legends */
    lateinit var slug: String
    /** sports_table.name of the game node, e.g. ESPORTS_LOL */
    lateinit var sport: String
    var minutesPerGame: Long = 45
}
