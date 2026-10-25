package ch.boosters.backend.config

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.stereotype.Component

@Component
@ConfigurationProperties(prefix = "frontend")
class FrontendProperties {
    /** Base URL of the web app, used for links in the calendar feeds. */
    var url: String = "https://synci.ch"
}
