package ch.boosters.backend.sources.pandascore

import arrow.core.Either
import arrow.core.raise.either
import arrow.core.raise.ensure
import ch.boosters.backend.config.SYNC_INTERVAL
import ch.boosters.backend.data.team.teamSports.TeamSportsRepository
import ch.boosters.backend.errorhandling.ElementNotFound
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.backend.sources.common.SourceSyncRepository
import ch.boosters.backend.sources.common.futureOnly
import ch.boosters.backend.sources.pandascore.model.PandaScoreMatch
import org.springframework.stereotype.Service
import java.time.LocalDateTime

/**
 * E-sport schedules from PandaScore: per configured game, the upcoming matches of top-tier
 * tournaments are stored below a league node (created on the fly) under the game node.
 */
@Service
class PandaScoreService(
    private val config: PandaScoreConfig,
    private val client: PandaScoreClient,
    private val syncRepository: SourceSyncRepository,
    private val teamSportsRepository: TeamSportsRepository,
) {

    fun update(): SynciEither<Unit> = either {
        if (config.token.isNullOrBlank()) {
            println("PandaScore: PANDASCORE_TOKEN missing, skipping")
            return Either.Right(Unit)
        }
        val sourceName = config.name
        ensure(sourceName != null) { ElementNotFound("Missing source name in pandascore configuration") }
        val sourceId = syncRepository.sourceIdByName(sourceName).bind()

        val lastSync = syncRepository.lastSyncTime(sourceId).bind()
        // shorter than interval, otherwise every second run is skipped
        if (lastSync != null && lastSync.isAfter(LocalDateTime.now().minus(SYNC_INTERVAL).plusHours(1))) {
            return Either.Right(Unit)
        }

        config.games.forEach { game ->
            val matches = client.upcomingMatches(game.slug).bind()
            storeGame(sourceId, game, matches).bind()
        }
        syncRepository.storeSyncTime(sourceId).bind()
    }

    private fun storeGame(sourceId: Int, game: PandaScoreGame, matches: List<PandaScoreMatch>): SynciEither<Unit> = either {
        syncRepository.deleteEvents(sourceId, matches.filter(PandaScoreMapper::isCanceled).map { it.id.toString() }).bind()

        val relevant = matches.filter { PandaScoreMapper.isRelevantTier(it, config) }
        val leagues = relevant.map { it.league }.distinctBy { it.id }
        println("PandaScore: ${game.slug} -> ${matches.size} upcoming matches, ${relevant.size} in tiers ${config.tiers}, ${leagues.size} leagues")

        val leagueIds = leagues.associate { league ->
            val node = PandaScoreMapper.leagueNodeName(league)
            node to syncRepository.upsertSportNode(node, league.name, game.sport).bind()
        }

        val mapped = relevant.mapNotNull { PandaScoreMapper.map(it, game, config) }
        mapped.groupBy { it.leagueNode }.forEach { (node, inLeague) ->
            val sportId = leagueIds.getValue(node)
            val withTeams = inLeague.filterIsInstance<MappedMatch.WithTeams>()
            val names = withTeams.associate { it.event.id to it.name }
            val teamEvents = withTeams.map { it.event }.futureOnly()
            val teams = PandaScoreMapper.teamsOf(teamEvents, sourceId)

            syncRepository.upsertTeams(teams).bind()
            teamSportsRepository.upsertTeams(teams, sportId).bind()
            syncRepository.upsertTeamEvents(sourceId, sportId, teamEvents) { names[it.id] ?: "${it.homeName} - ${it.awayName}" }.bind()
            syncRepository.upsertEvents(sourceId, sportId, inLeague.filterIsInstance<MappedMatch.WithoutTeams>().map { it.event }.futureOnly()).bind()
        }
    }
}
