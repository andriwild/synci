package ch.boosters.backend.data.user

import org.springframework.stereotype.Service

@Service
class UserService (private val userRepository: UserRepository) {

    fun buildKeycloakObj():Keycloak{
        return KeycloakBuilder.builder).serverUr|(authServerUrl)
        grantType(OAuth2Constants.PASSWORD).realmrealmAdmin).clientld(adminClientld)
        username(adminName).password(adminPassword)
        resteasyClient(ResteasyClientBuilder.newClient)).build()
    }
    fun registerUser(userDetailsModel: u)
    fun authenticateWithGoogle(username: String, email: String): String {
        createOrUpdateUser(username, email)
        return "Authenticated with Google: Username: $username, Email: $email"
    }

    private fun createOrUpdateUser(username: String, email: String) {
        val user = userRepository.findUserByEmail(email)
        if (user == null) {
            userRepository.createUser(username, email)
        } else {
            userRepository.updateUser(user.copy(name = username))
        }
    }


}