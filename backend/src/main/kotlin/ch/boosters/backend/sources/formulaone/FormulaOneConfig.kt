package ch.boosters.backend.sources.formulaone

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.context.annotation.Configuration

@ConfigurationProperties(prefix = "formulaone")
@Configuration
class FormulaOneConfig {
    var url: String? = null
    var name: String? = null
    var sport: String? = null
}