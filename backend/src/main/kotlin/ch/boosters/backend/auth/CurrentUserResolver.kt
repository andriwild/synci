package ch.boosters.backend.auth

import ch.boosters.backend.errorhandling.InvalidUser
import ch.boosters.backend.errorhandling.SynciEither
import org.jooq.DSLContext
import org.springframework.security.core.Authentication
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Component
import java.util.UUID
import arrow.core.raise.ensureNotNull
import arrow.core.raise.either
import ch.boosters.data.tables.references.USERS_TABLE


@Component
class CurrentUserResolver(private val dsl: DSLContext) {

    fun getUserId(authentication: Authentication): SynciEither<UUID> = either {
        val jwt = authentication.principal as? Jwt
            ?: raise(InvalidUser("Kein gültiges JWT"))

        val auth0Id = jwt.subject

        val userId = dsl
            .select(USERS_TABLE.ID)
            .from(USERS_TABLE)
            .where(USERS_TABLE.AUTH0_ID.eq(auth0Id))
            .fetchOne(USERS_TABLE.ID)

        ensureNotNull(userId) {
            InvalidUser("Kein Benutzer für Auth0-ID $auth0Id gefunden")
        }
    }
}
