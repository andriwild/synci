package ch.boosters.backend.config

import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.core.convert.converter.Converter
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.core.GrantedAuthority
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.oauth2.jwt.JwtDecoders
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter
import org.springframework.security.web.SecurityFilterChain

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
class SecurityConfiguration(
    @Value("\${spring.security.oauth2.client.provider.synci-keycloak.issuer-uri}")
    private val issuerUri: String,
) {

    private val clientName: String = "synci-backend"
    @Bean
    fun filterChain(http: HttpSecurity): SecurityFilterChain {
        http.csrf { it.disable() }
            .authorizeHttpRequests {
                it.requestMatchers("/swissski/list").permitAll()
                    .requestMatchers("/team/list").permitAll()
                    .anyRequest().authenticated()
            }
            .oauth2ResourceServer {
                it.jwt { jwt ->
                    jwt.decoder(JwtDecoders.fromIssuerLocation(issuerUri))
                    jwt.jwtAuthenticationConverter(customJwtAuthenticationConverter())
                }
            }
            .sessionManagement {
                it.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            }

        return http.build()
    }

    @Bean
    fun customJwtAuthenticationConverter(): JwtAuthenticationConverter {
        println("clientName: $clientName")
        return JwtAuthenticationConverter().apply {
            setJwtGrantedAuthoritiesConverter(customJwtGrantedAuthoritiesConverter())
        }
    }

    @Bean
    fun customJwtGrantedAuthoritiesConverter(): Converter<Jwt, Collection<GrantedAuthority>> {
        return CustomJwtGrantedAuthoritiesConverter(clientName)
    }
}
