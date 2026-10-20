package ch.boosters.backend.data.team

import ch.boosters.data.enums.GenderType

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

    fun toGenderType(): GenderType = GenderType.valueOf(name)
}

data class Team(
    val id: String,
    val source: Int,
    val name: String,
    val gender: Gender,
    val logoUrl: String? = null,
)