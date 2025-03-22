package ch.boosters.backend.util

import arrow.core.Either
import ch.boosters.backend.errorhandling.InvalidUser
import ch.boosters.backend.errorhandling.SynciEither
import org.springframework.security.core.Authentication
import java.util.UUID

fun Authentication.userId(): SynciEither<UUID> =
    Either
        .catch { UUID.fromString(this.name) }
        .mapLeft { InvalidUser("User with name ${this.name} is not valid ") }