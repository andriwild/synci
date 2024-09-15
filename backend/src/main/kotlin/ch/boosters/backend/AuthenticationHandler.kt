package ch.boosters.backend

import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.security.authentication.AuthenticationServiceException
import org.springframework.security.core.GrantedAuthority
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken
import org.springframework.stereotype.Component
import java.util.*


@Component
class AuthenticationHandler(userService: UserService) {
    private val userService: UserService = userService

    fun handle(
        source: JwtAuthenticationToken,
        request: HttpServletRequest,
        response: HttpServletResponse?
    ): JwtAuthenticationToken {
        if (!source.isAuthenticated) throw AuthenticationServiceException("not authenticated")
        val (user, jwt) = resolveUserAndJwt(source)
        return createTokenForUser(jwt, user)
    }

    private fun resolveUserAndJwt(source: JwtAuthenticationToken): Pair<User, Jwt> {
        val uid = source.name
        val jwt = source.token
        val maybeUser: Optional<User> = userService.getByUidInitialized(uid)
        val user: User?
        if (maybeUser.isEmpty()) {
            user = userService.createNewUser(uid, "TBD ELias")
            if (user == null) {
                throw AuthenticationServiceException("Cannot create user")
            }
        } else {
            user = maybeUser.get()
        }
        return Pair(user, jwt)
    }

    private fun createTokenForUser(jwt: Jwt, user: User): JwtAuthenticationToken {
        val authorities = ArrayList<GrantedAuthority>()
        val token = JwtAuthenticationToken(jwt, authorities, user.toString())
        token.isAuthenticated = true
        return token
    }


//    private fun getProfileDetailsGoogle(accessToken: String) {
//        val restTemplate = RestTemplate()
//        val httpHeaders = HttpHeaders()
//        httpHeaders.setBearerAuth(accessToken)
//
//        val requestEntity = HttpEntity<String>(httpHeaders)
//
//        val url = "https://www.googleapis.com/oauth2/v2/userinfo"
//        val response = restTemplate.exchange<String>(
//            url, HttpMethod.GET, requestEntity,
//            String::class.java
//        )
//        val jsonObject: JsonObject = Gson().fromJson(response.body, JsonObject::class.java)
//        println(jsonObject)
//    }
}
