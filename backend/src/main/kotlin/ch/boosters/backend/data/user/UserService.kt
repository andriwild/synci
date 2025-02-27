package ch.boosters.backend.data.user

import org.springframework.stereotype.Service

@Service
class UserService (private val userRepository: UserRepository) {

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