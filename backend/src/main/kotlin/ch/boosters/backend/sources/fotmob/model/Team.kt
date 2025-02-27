package ch.boosters.backend.sources.fotmob.model

import kotlinx.serialization.Serializable

@Serializable
data class Team(val name: String, val id: Int)
