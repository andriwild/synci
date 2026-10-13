package ch.boosters.backend.auth

import arrow.core.raise.either
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.tables.references.USERS_TABLE
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

data class UserProfileDto(val email: String?, val name: String?)

/**
 * The access token carries no email or name, so the frontend reports the profile it got from Auth0
 * after login. The values are shown in member lists of organisations.
 */
@RestController
@RequestMapping("/users")
@PreAuthorize("isAuthenticated()")
class UserController(
    private val dsl: JooqEitherDsl,
    private val currentUserResolver: CurrentUserResolver
) {

    @PutMapping("/me")
    fun updateProfile(@RequestBody profile: UserProfileDto, authentication: Authentication): SynciEither<Int> = either {
        val userId = currentUserResolver.getUserId(authentication).bind()
        dsl {
            it.update(USERS_TABLE)
                .set(USERS_TABLE.EMAIL, profile.email?.trim()?.ifEmpty { null })
                .set(USERS_TABLE.NAME, profile.name?.trim()?.ifEmpty { null })
                .where(USERS_TABLE.ID.eq(userId))
                .execute()
        }.bind()
    }
}
