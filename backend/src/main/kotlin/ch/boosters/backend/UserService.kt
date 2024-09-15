package ch.boosters.backend

import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken
import org.springframework.stereotype.Service
import org.springframework.util.Assert
import java.util.*

@Service
class UserService {
    val authenticatedUser: Optional<User>
        //    private final UserRepository userRepository;
        get() {
            val authentication = SecurityContextHolder.getContext().authentication
                ?: return Optional.empty()
            Assert.isInstanceOf(
                JwtAuthenticationToken::class.java,
                authentication,
                "Only JwtAuthenticationToken is supported"
            )

            return getByUidInitialized(authentication.name)
        }

    fun getByUidInitialized(uid: String?): Optional<User> {
//        return userRepository.findUserByUid(uid);
        return Optional.empty()
    }

    fun createNewUser(uid: String?, name: String?): User {
        val user = User(uid!!, name!!)
        //        return userRepository.save(user);
        return user
    }
}