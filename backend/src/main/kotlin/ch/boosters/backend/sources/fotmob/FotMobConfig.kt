package ch.boosters.backend.sources.fotmob

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.context.annotation.Configuration

@ConfigurationProperties(prefix = "fotmob")
@Configuration
class FotMobConfig {
    var url: String? = null
    var name: String? = null
    var leagues: MutableList<FotMobLeague> = mutableListOf()
}

class FotMobLeague {
    lateinit var id: String
    lateinit var name: String
}
