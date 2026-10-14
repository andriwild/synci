package ch.boosters.backend.data.user

import arrow.core.raise.either
import ch.boosters.backend.auth.CurrentUserResolver
import ch.boosters.backend.errorhandling.SynciEither
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/users")
@PreAuthorize("isAuthenticated()")
class UserController(
    private val userService: UserService,
    private val currentUserResolver: CurrentUserResolver
) {
    @DeleteMapping("/me")
    fun deleteCurrentUser(authentication: Authentication): SynciEither<Int> = either {
        val userId = currentUserResolver.getUserId(authentication).bind()
        // The name is the "sub" claim, i.e. the Auth0 ID
        return userService.deleteUser(userId, authentication.name)
    }
}
