package ch.boosters.backend.data.syncConfig.syncConfigMatchups

import arrow.core.raise.either
import arrow.core.raise.ensure
import ch.boosters.backend.data.syncConfig.model.MatchupDto
import ch.boosters.backend.errorhandling.InvalidRequest
import ch.boosters.backend.errorhandling.SynciEither

/** How many Top Events one Abo may hold. */
const val MATCHUP_LIMIT = 20

/** Drops repeats (A – B equals B – A, the first one wins) and checks the rules. */
fun normalizeMatchups(matchups: List<MatchupDto>): SynciEither<List<MatchupDto>> = either {
    ensure(matchups.none { it.teamAId == it.teamBId }) { InvalidRequest("Ein Top Event braucht zwei verschiedene Teams") }
    val distinct = matchups.distinctBy { it.sourceId to setOf(it.teamAId, it.teamBId) }
    ensure(distinct.size <= MATCHUP_LIMIT) { InvalidRequest("Ein Abo kann höchstens $MATCHUP_LIMIT Top Events enthalten") }
    distinct
}
