package ch.boosters.backend.sources.swisstxt

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.context.annotation.Configuration

@ConfigurationProperties(prefix = "swisstxt")
@Configuration
class SwissTxtConfig {
    var name: String? = null
    var url: String? = null
    var id: Int? = null
    var teamSport: MutableList<SwissTxtTeamSport> = mutableListOf()
    var events: MutableList<SwissTxtEventSport> = mutableListOf()
}

class SwissTxtTeamSport {
    lateinit var name: String
    lateinit var id: String
    var leagues: MutableList<SwissTxtSportLeague> = mutableListOf()
}

class SwissTxtEventSport {
    lateinit var name: String
    lateinit var id: String
    lateinit var disciplines: MutableList<SwissTxtEventDisciplines>
}

class SwissTxtEventDisciplines {
    lateinit var name: String
    lateinit var id: String
    lateinit var leagues: MutableList<SwissTxtSportLeague>
}

class SwissTxtSportLeague {
    lateinit var id: String
    lateinit var name: String
    var includeAll: Boolean = false
    var phases: MutableList<String> = mutableListOf()
}