package ch.boosters.backend.auth

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.stereotype.Component

@Component
@ConfigurationProperties(prefix = "auth0.management")
class Auth0ManagementProperties {
    // Tenant domain (e.g. synci.eu.auth0.com), not the custom domain: the Management API only accepts its audience
    var domain: String = ""
    var clientId: String = ""
    var clientSecret: String = ""
}
