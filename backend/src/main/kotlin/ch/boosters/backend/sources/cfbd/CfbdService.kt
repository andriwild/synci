package ch.boosters.backend.sources.cfbd

import arrow.core.Either
import arrow.core.raise.either
import arrow.core.raise.ensure
import ch.boosters.backend.config.SYNC_INTERVAL
import ch.boosters.backend.data.team.teamSports.TeamSportsRepository
import ch.boosters.backend.errorhandling.ElementNotFound
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.backend.sources.common.SourceSyncRepository
import ch.boosters.backend.sources.common.futureOnly
import org.springframework.stereotype.Service
import java.time.LocalDateTime

/**
 * College football schedules from CollegeFootballData: upcoming games of the season are stored below a
 * conference node (created on the fly) or, for bowls and the playoff, below NCAA_POSTSEASON.
 * Every team is also linked to its own conference, so a team subscription finds all its games.
 */
@Service
class CfbdService(
    private val config: CfbdConfig,
    private val client: CfbdClient,
    private val syncRepository: SourceSyncRepository,
    private val teamSportsRepository: TeamSportsRepository,
) {

    fun update(): SynciEither<Unit> = either {
        if (config.token.isNullOrBlank()) {
            println("CFBD: CFBD_TOKEN missing, skipping")
            return Either.Right(Unit)
        }
        val sourceName = config.name
        ensure(sourceName != null) { ElementNotFound("Missing source name in cfbd configuration") }
        val sourceId = syncRepository.sourceIdByName(sourceName).bind()

        val lastSync = syncRepository.lastSyncTime(sourceId).bind()
        // shorter than interval, otherwise every second run is skipped
        if (lastSync != null && lastSync.isAfter(LocalDateTime.now().minus(SYNC_INTERVAL).plusHours(1))) {
            return Either.Right(Unit)
        }

        val season = CfbdGameMapper.season(config)
        val games = client.games(season).bind()
        val upcoming = games.mapNotNull { CfbdGameMapper.map(it, config) }
        val withoutTime = games.count { it.startTimeTBD && !it.completed }
        println("CFBD: season $season -> ${games.size} games, ${upcoming.size} with kickoff time, $withoutTime without time yet")

        val labels = CfbdGameMapper.conferences(games, config) + (CfbdGameMapper.POSTSEASON_NODE to "Bowls & Playoff")
        val nodeIds = labels.mapValues { (node, label) ->
            syncRepository.upsertSportNode(node, label, CfbdGameMapper.CONFERENCE_PARENT_NODE).bind()
        }

        CfbdGameMapper.teamsByConference(games, sourceId, config).forEach { (node, teams) ->
            syncRepository.upsertTeams(teams).bind()
            teamSportsRepository.upsertTeams(teams, nodeIds.getValue(node)).bind()
        }

        upcoming.groupBy { it.sportNode }.forEach { (node, inNode) ->
            val names = inNode.associate { it.event.id to it.name }
            val events = inNode.map { it.event }.futureOnly()
            // opponents outside the classification (e.g. FCS) are only known through their games
            syncRepository.upsertTeams(CfbdGameMapper.teamsOf(events, sourceId)).bind()
            syncRepository.upsertTeamEvents(sourceId, nodeIds.getValue(node), events) { names[it.id] ?: "${it.homeName} - ${it.awayName}" }.bind()
        }
        syncRepository.storeSyncTime(sourceId).bind()
    }
}
