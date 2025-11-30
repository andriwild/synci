package ch.boosters.backend.data.team

enum class Gender(val displayName: String) {
    MAN("Man"),
    WOMAN("Woman"),
    BOTH("Both"),
    UNKNOWN("Unknown");

    companion object {
        fun fromString(name: String): Gender  {
            return Gender.entries.find{ it.displayName == name} ?: UNKNOWN
        }
    }
}

data class Team(
    val id: String,
    val source: Int,
    val name: String,
    val gender: Gender
)