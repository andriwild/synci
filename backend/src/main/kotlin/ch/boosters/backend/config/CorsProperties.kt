package ch.boosters.backend.config

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.stereotype.Component


@Component
@ConfigurationProperties(prefix = "cors")
class CorsProperties {
    // Getters and Setters
    var allowedOrigins: String = ""
}
