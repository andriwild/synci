package ch.boosters.backend.data.user

import io.jsonwebtoken.Jwts
import jakarta.servlet.http.HttpServletRequest
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController


@RestController
@RequestMapping("/auth")
class LoginController(private val userService: UserService) {
    @PostMapping("/google")
    fun googleAuth(@AuthenticationPrincipal jwt: Jwt): String {
        val username = jwt.getClaim<String>("name")
        val email = jwt.getClaim<String>("email")

        // validate the token
        return userService.authenticateWithGoogle(username, email)

    }

}