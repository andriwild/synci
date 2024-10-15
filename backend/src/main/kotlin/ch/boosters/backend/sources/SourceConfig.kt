package ch.boosters.backend.sources

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.context.annotation.Configuration

@ConfigurationProperties(prefix = "sources")
@Configuration
class SourceConfig{
    var fotMob: FotMobSource = FotMobSource()
    var swissSki: SwissSkiSource = SwissSkiSource()
}

class FotMobSource {
    var url: String? = null
    var name: String? = null
    var leagues: MutableList<FotMobLeague> = mutableListOf()
}

class FotMobLeague {
    lateinit var id: String
    lateinit var name: String
}

class SwissSkiSource {
    var url: String? = null
    var name: String? = null
    var sport: String? = null
}
