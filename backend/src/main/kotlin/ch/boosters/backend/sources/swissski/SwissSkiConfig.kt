package ch.boosters.backend.sources.swissski

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.context.annotation.Configuration

@ConfigurationProperties(prefix = "swissski")
@Configuration
class SwissSkiConfig {
    var url: String? = null
    var name: String? = null
    var sport: String? = null
}