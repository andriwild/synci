package ch.boosters.backend.sources.cfbd

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.context.annotation.Configuration

/** Bound from sources/cfbd.yml */
@ConfigurationProperties(prefix = "cfbd")
@Configuration
class CfbdConfig {
    var name: String? = null
    var url: String = "https://api.collegefootballdata.com"
    var token: String? = null
    var classification: String = "fbs"
    /** null = derived from today, see CfbdGameMapper.season */
    var season: Int? = null
    var timezone: String = "Europe/Zurich"
    var gameDurationMinutes: Long = 210
}
