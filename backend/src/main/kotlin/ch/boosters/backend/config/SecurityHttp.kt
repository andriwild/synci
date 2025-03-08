package ch.boosters.backend.config

import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.annotation.web.configurers.oauth2.server.resource.OAuth2ResourceServerConfigurer
import org.springframework.security.oauth2.jwt.JwtDecoders
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter
import org.springframework.security.web.SecurityFilterChain

@EnableWebSecurity
@Configuration
class SecurityHttp {

    @Value("\${spring.security.oauth2.resourceserver.jwt.issuer-uri}")
    var issuerUri: String? = null

    @Value("\${application.client}")
    var clientName: String? = null

    @Bean
    @Throws(Exception::class)
    fun filterChain(http: HttpSecurity): SecurityFilterChain? {
        http.authorizeHttpRequests { authz -> authz
//            .requestMatchers("/api/**").permitAll()
            .anyRequest().authenticated()
        }
        http.oauth2ResourceServer { obj: OAuth2ResourceServerConfigurer<HttpSecurity?> ->
            obj.jwt{ obj: OAuth2ResourceServerConfigurer.JwtConfigurer ->
                obj.decoder(JwtDecoders.fromIssuerLocation(issuerUri))
                    .jwtAuthenticationConverter(customJwtAuthencationConverter()))
        }
        return http.build()
    }

        @Bean
        fun customJwtAuthencationConverter(): JwtAuthenticationConverter {
            val converter = JwtAuthenticationConverter()
            converter.setJwtGrantedAuthoritiesConverter(customJwtGrantedAuthoritiesConverter())
            return converter
        }

}