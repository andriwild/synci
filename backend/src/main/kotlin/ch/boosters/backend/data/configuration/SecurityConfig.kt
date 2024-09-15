package ch.boosters.backend

import jakarta.annotation.Resource
import jakarta.servlet.FilterChain
import jakarta.servlet.ServletException
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.slf4j.MDC
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.Customizer
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configurers.CorsConfigurer
import org.springframework.security.config.annotation.web.configurers.CsrfConfigurer
import org.springframework.security.config.annotation.web.configurers.SessionManagementConfigurer
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.oauth2.jwt.JwtDecoder
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken
import org.springframework.security.oauth2.server.resource.authentication.JwtGrantedAuthoritiesConverter
import org.springframework.security.oauth2.server.resource.web.authentication.BearerTokenAuthenticationFilter
import org.springframework.security.web.SecurityFilterChain
import org.springframework.web.filter.OncePerRequestFilter
import java.io.IOException


@Configuration
class SecurityConfig {

    @Resource
    private val authenticationHandler: AuthenticationHandler? = null

    @Bean
    fun jwtDecoder(): JwtDecoder {
        return NimbusJwtDecoder.withJwkSetUri("https://www.googleapis.com/oauth2/v3/certs").build()
    }



    @Bean
    @Throws(Exception::class)
    fun securityFilterChain(http: HttpSecurity): SecurityFilterChain {
        http
            .cors(Customizer.withDefaults<CorsConfigurer<HttpSecurity>>())
            .authorizeHttpRequests { requests ->
                requests.requestMatchers("/grantcode").permitAll()
                requests.anyRequest().authenticated()
            }
            .sessionManagement { sessionManagement: SessionManagementConfigurer<HttpSecurity?> ->
                sessionManagement.sessionCreationPolicy(
                    SessionCreationPolicy.STATELESS
                )
            }
            .csrf { csrf: CsrfConfigurer<HttpSecurity> -> csrf.disable() }
            .oauth2ResourceServer { oauth2ResourceServer ->
                oauth2ResourceServer.jwt { jwt ->
                    jwt.jwtAuthenticationConverter(
                        JwtAuthenticationConverter().apply {
                            setJwtGrantedAuthoritiesConverter(JwtGrantedAuthoritiesConverter())
                        }
                    )
                }
            }
        setupAuthorizationHandler(http)
        return http.build()
    }


    private fun setupAuthorizationHandler(http: HttpSecurity){
        http.addFilterAfter(
            authenticationHandler?.let { AuthenticationHandlerFilter(it) },
            BearerTokenAuthenticationFilter::class.java
        )
    }

    class AuthenticationHandlerFilter(private val authenticationHandler: AuthenticationHandler) :
        OncePerRequestFilter() {


        @Throws(ServletException::class, IOException::class)
        override fun doFilterInternal(
            request: HttpServletRequest,
            response: HttpServletResponse,
            filterChain: FilterChain
        ) {
            var authentication = SecurityContextHolder.getContext().authentication
            if (authentication is JwtAuthenticationToken) {
                try {
                    authentication = authenticationHandler.handle(authentication, request, response)
                } catch (e: Exception) {
                    response.setHeader("WWW-Authenticate", "Bearer error=\"invalid_token\"")
                    throw ServletException(e)
                }
                SecurityContextHolder.getContext().authentication = authentication
            }
            filterChain.doFilter(request, response)
        }
    }
}

