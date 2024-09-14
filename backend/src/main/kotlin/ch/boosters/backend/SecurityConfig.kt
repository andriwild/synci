package ch.boosters.backend

import com.google.gson.Gson
import com.google.gson.JsonObject
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.http.HttpEntity
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpMethod
import org.springframework.security.config.Customizer
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configurers.AuthorizeHttpRequestsConfigurer.AuthorizationManagerRequestMatcherRegistry
import org.springframework.security.config.annotation.web.configurers.CorsConfigurer
import org.springframework.security.config.annotation.web.configurers.CsrfConfigurer
import org.springframework.security.config.annotation.web.configurers.SessionManagementConfigurer
import org.springframework.security.config.annotation.web.configurers.oauth2.server.resource.OAuth2ResourceServerConfigurer
import org.springframework.security.config.annotation.web.configurers.oauth2.server.resource.OAuth2ResourceServerConfigurer.JwtConfigurer
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter
import org.springframework.security.oauth2.server.resource.authentication.JwtGrantedAuthoritiesConverter
import org.springframework.security.web.SecurityFilterChain
import org.springframework.web.client.RestTemplate


@Configuration
class SecurityConfig {

    @Bean
    @Throws(Exception::class)
    fun securityFilterChain(http: HttpSecurity): SecurityFilterChain {
        http
            .cors(Customizer.withDefaults<CorsConfigurer<HttpSecurity>>())
            .authorizeHttpRequests(
                Customizer { requests: AuthorizationManagerRequestMatcherRegistry ->
                    requests.anyRequest().authenticated()
                }
            )
            .sessionManagement { sessionManagement: SessionManagementConfigurer<HttpSecurity?> ->
                sessionManagement.sessionCreationPolicy(
                    SessionCreationPolicy.STATELESS
                )
            }
            .csrf { csrf: CsrfConfigurer<HttpSecurity> -> csrf.disable() }
            .oauth2ResourceServer { oauth2ResourceServer: OAuth2ResourceServerConfigurer<HttpSecurity?> ->
                oauth2ResourceServer.jwt { jwt: JwtConfigurer<HttpSecurity?> ->
                    jwt.jwtAuthenticationConverter(
                        JwtAuthenticationConverter().apply {
                            setJwtGrantedAuthoritiesConverter(
                                JwtGrantedAuthoritiesConverter()
                            )
                        }
                    )
                }
            }

        setupAuthorizationHandler(http)
        return http.build()
    }

    private fun getProfileDetailsGoogle(accessToken: String) {
        val restTemplate = RestTemplate()
        val httpHeaders = HttpHeaders()
        httpHeaders.setBearerAuth(accessToken)

        val requestEntity = HttpEntity<String>(httpHeaders)

        val url = "https://www.googleapis.com/oauth2/v2/userinfo"
        val response = restTemplate.exchange<String>(
            url, HttpMethod.GET, requestEntity,
            String::class.java
        )
        val jsonObject: JsonObject = Gson().fromJson(response.body, JsonObject::class.java)
        println(jsonObject)
    }
}