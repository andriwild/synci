package ch.boosters.backend.sources.nflverse.model

import java.time.LocalDate
import java.time.LocalTime

/** One row of the nflverse games.csv (only the columns Synci needs). */
data class NflGame(
    /** e.g. 2026_07_NE_CHI */
    val gameId: String,
    val season: Int,
    /** REG, WC, DIV, CON, SB */
    val gameType: String,
    val week: Int,
    val gameday: LocalDate,
    /** kickoff in US Eastern Time, null while the league has not fixed the time yet */
    val gametime: LocalTime?,
    val awayTeam: String,
    val homeTeam: String,
    /** Home or Neutral */
    val location: String,
    val stadium: String?,
) {
    val isNeutralSite: Boolean get() = location.equals("Neutral", ignoreCase = true)
}
