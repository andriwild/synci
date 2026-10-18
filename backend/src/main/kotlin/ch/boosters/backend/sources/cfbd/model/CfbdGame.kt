package ch.boosters.backend.sources.cfbd.model

import kotlinx.serialization.Serializable

/** Subset of a CollegeFootballData game (GET /games); unknown fields are ignored. */
@Serializable
data class CfbdGame(
    val id: Long,
    val season: Int,
    /** regular or postseason */
    val seasonType: String,
    /** UTC, ISO-8601, e.g. 2026-10-17T19:30:00.000Z */
    val startDate: String,
    /** the date is fixed but the kickoff time is not announced yet */
    val startTimeTBD: Boolean = false,
    val completed: Boolean = false,
    val homeId: Long,
    val homeTeam: String,
    val homeConference: String? = null,
    val homeClassification: String? = null,
    val awayId: Long,
    val awayTeam: String,
    val awayConference: String? = null,
    val awayClassification: String? = null,
    /** e.g. the bowl name for postseason games */
    val notes: String? = null,
)
