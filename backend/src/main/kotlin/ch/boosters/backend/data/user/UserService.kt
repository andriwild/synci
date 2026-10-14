package ch.boosters.backend.data.user

import arrow.core.raise.either
import ch.boosters.backend.auth.Auth0ManagementClient
import ch.boosters.backend.errorhandling.SynciEither
import org.springframework.stereotype.Service
import java.util.UUID

@Service
class UserService(
    private val userRepository: UserRepository,
    private val auth0ManagementClient: Auth0ManagementClient,
) {

    // Auth0 first, so a failure keeps the data and can be retried.
    // Clients must log out right away, otherwise UserProvisioningFilter recreates the user.
    fun deleteUser(userId: UUID, auth0Id: String): SynciEither<Int> = either {
        auth0ManagementClient.deleteUser(auth0Id).bind()
        userRepository.deleteUserWithSyncConfigs(userId).bind()
    }
}
