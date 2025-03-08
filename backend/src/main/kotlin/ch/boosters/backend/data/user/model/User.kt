package ch.boosters.backend.data.user.model

data class User(
    val userName: String,
    val email: String,
    val password: String,
    val keyCloakId: String
)
