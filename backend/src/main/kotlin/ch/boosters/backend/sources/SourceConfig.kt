package ch.boosters.backend.sources

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.context.annotation.Configuration

@ConfigurationProperties(prefix = "sources")
@Configuration
class SourceConfig{
    var fotmob: Source = Source()
}

class Source {
    var url: String? = null
    var name: String? = null
    var leagues: MutableList<League> = mutableListOf()
}

class League {
    lateinit var id: String
    lateinit var name: String
}
