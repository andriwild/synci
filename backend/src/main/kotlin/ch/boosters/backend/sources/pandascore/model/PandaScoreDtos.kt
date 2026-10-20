package ch.boosters.backend.sources.pandascore.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/** Subset of a PandaScore match (GET /matches/upcoming); unknown fields are ignored. */
@Serializable
data class PandaScoreMatch(
    val id: Long,
    val name: String? = null,
    /** UTC, ISO-8601, e.g. 2026-10-15T18:00:00Z */
    @SerialName("scheduled_at") val scheduledAt: String? = null,
    val status: String? = null,
    @SerialName("number_of_games") val numberOfGames: Int? = null,
    val league: PandaScoreLeague,
    val tournament: PandaScoreTournament? = null,
    val opponents: List<PandaScoreOpponent> = emptyList(),
)

@Serializable
data class PandaScoreLeague(
    val id: Long,
    val name: String,
    val slug: String? = null,
)

@Serializable
data class PandaScoreTournament(
    val id: Long? = null,
    val name: String? = null,
    /** s, a, b, c, d or unranked */
    val tier: String? = null,
)

@Serializable
data class PandaScoreOpponent(
    /** Team or Player */
    val type: String? = null,
    val opponent: PandaScoreTeam,
)

@Serializable
data class PandaScoreTeam(
    val id: Long,
    val name: String,
    val acronym: String? = null,
    @SerialName("image_url") val imageUrl: String? = null,
)
