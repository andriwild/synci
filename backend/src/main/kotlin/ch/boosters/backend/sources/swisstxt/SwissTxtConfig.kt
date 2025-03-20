package ch.boosters.backend.sources.swisstxt

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.context.annotation.Configuration

@ConfigurationProperties(prefix = "swisstxt")
@Configuration
class SwissTxtConfig {
    var name: String? = null
    var url: String? = null
    var id: Int? = null
    var sport: MutableList<SwissTxtSport> = mutableListOf()
}

class SwissTxtSport {
    lateinit var key: String
    var leagues: MutableList<SwissTxtLeague> = mutableListOf()
}

class SwissTxtLeague {
    lateinit var id: String
    lateinit var name: String
}