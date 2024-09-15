package ch.boosters.backend;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Service;
import org.springframework.util.Assert;

import java.util.List;
import java.util.Optional;

@Service
public class UserService {
//    private final UserRepository userRepository;

//    public UserService(UserRepository userRepository) {
//        this.userRepository = userRepository;
//    }

    public Optional<User> getAuthenticatedUser() {
        final var authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null) {
            return Optional.empty();
        }
        Assert.isInstanceOf(JwtAuthenticationToken.class, authentication, "Only JwtAuthenticationToken is supported");

        return getByUidInitialized(authentication.getName());
    }

    public Optional<User> getByUidInitialized(String uid) {
//        return userRepository.findUserByUid(uid);
        return Optional.empty();
    }

    public User createNewUser(String uid, String name) {
        var user = new User(uid, name);
//        return userRepository.save(user);
        return user;
    }
}