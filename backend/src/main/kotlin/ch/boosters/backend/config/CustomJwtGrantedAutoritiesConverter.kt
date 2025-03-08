package ch.boosters.backend.config

import org.springframework.core.convert.converter.Converter
import org.springframework.security.core.GrantedAuthority
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.oauth2.jwt.Jwt

class CustomJwtGrantedAuthoritiesConverter(
    private val clientName: String
) : Converter<Jwt, Collection<GrantedAuthority>> {

    override fun convert(jwt: Jwt): Collection<GrantedAuthority> {
        val finalRoles = mutableListOf<GrantedAuthority>()
        extractRealmRoles(jwt.getClaim("realm_access"), finalRoles)
        extractClientRoles(jwt, finalRoles)
        return finalRoles
    }

    private fun extractRealmRoles(mapObject: Any?, finalRoles: MutableCollection<GrantedAuthority>) {
        if (mapObject is Map<*, *>) {
            val rolesMap = mapObject["roles"] as? List<String>
            rolesMap?.forEach { role -> finalRoles.add(SimpleGrantedAuthority(role)) }
        }
    }

    private fun extractClientRoles(jwt: Jwt, finalRoles: MutableCollection<GrantedAuthority>) {
        val resourceAccessMap = jwt.getClaim<Map<String, Map<String, List<String>>>>("resource_access")
        val clientAccessMap = resourceAccessMap?.get(clientName)
        val roles = clientAccessMap?.get("roles")
        roles?.forEach { role -> finalRoles.add(SimpleGrantedAuthority(role)) }
    }
}
