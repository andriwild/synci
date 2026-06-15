package ch.boosters.backend.data.syncConfig

import arrow.core.Either
import arrow.core.flatMap
import arrow.core.raise.either
import arrow.core.raise.ensure
import ch.boosters.backend.data.sport.SportsRepository
import ch.boosters.backend.data.sport.business.rootSportOf
import ch.boosters.backend.data.syncConfig.model.SyncConfigDto
import ch.boosters.backend.data.syncConfig.syncConfigEvents.SyncConfigEventsRepository
import ch.boosters.backend.data.syncConfig.syncConfigSports.SyncConfigSportsRepository
import ch.boosters.backend.data.syncConfig.syncConfigTeam.SyncConfigTeamRepository
import ch.boosters.backend.errorhandling.ElementNotFound
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.backend.errorhandling.SynciError
import ch.boosters.data.tables.pojos.SyncConfigsTable
import org.springframework.stereotype.Service
import java.util.UUID

@Service
class SyncConfigService(
    private val syncConfigRepository: SyncConfigRepository,
    private val syncConfigTeamRepository: SyncConfigTeamRepository,
    private val syncConfigSportsRepository: SyncConfigSportsRepository,
    private val syncConfigEventsRepository: SyncConfigEventsRepository,
    private val sportsRepository: SportsRepository
) {

    fun createSyncConfig(syncConfig: SyncConfigDto, userId: UUID): SynciEither<SyncConfig> = either {
        val cleanedConfig = removeDuplicates(syncConfig)
        val id = syncConfigRepository.createSyncConfig(cleanedConfig, userId).bind()
        syncConfigTeamRepository.addTeams(id, cleanedConfig.teams).bind()
        syncConfigSportsRepository.addSports(id, cleanedConfig.sports).bind()
        syncConfigEventsRepository.addEvents(id, cleanedConfig.events).bind()
        syncConfigById(id, userId).bind()
    }

    fun allSyncConfigsForUser(userId: UUID): SynciEither<List<SyncConfig>> = either {
        val configs = syncConfigRepository.findAllSyncConfigsByUser(userId).bind()
        configs.map { syncConfigById(it.id, userId) }.bindAll()
    }

    fun syncConfigById(id: UUID, userId: UUID): SynciEither<SyncConfig> = either {
        val syncConfig = syncConfigBelongsToUser(id, userId).bind()
        val sportsOfConfig = syncConfigSportsRepository.getSportsIdBySyncConfigId(id).bind()
        val teamsOfConfig = syncConfigTeamRepository.getTeamBySyncConfigId(id).bind()
        val eventIdsInConfig = syncConfigEventsRepository.getEventsIdsBySyncConfigId(id).bind()

        val allSports = sportsRepository.allSports().bind()
        val teamSportMap = syncConfigTeamRepository.getTeamSportPairsBySyncConfigId(id).bind()
            .groupBy({ it.first }, { it.second })

        fun rootLabel(sportId: UUID?): String? =
            allSports.rootSportOf(sportId)?.let { it.label ?: it.name }

        SyncConfig(
            id = id,
            name = syncConfig.name,
            teams = teamsOfConfig.map { WithRootSport(it, rootLabel(teamSportMap[it.id]?.firstOrNull())) },
            sports = sportsOfConfig.map { WithRootSport(it, rootLabel(it.id)) },
            events = eventIdsInConfig.map { WithRootSport(it, rootLabel(it.sportId)) },
        )
    }

    fun updateSyncConfig(id: UUID, syncConfig: SyncConfigDto, userId: UUID): SynciEither<SyncConfig> = either {
        val cleanedConfig = removeDuplicates(syncConfig)
        syncConfigRepository.updateSyncConfig(id, cleanedConfig).bind()
        syncConfigTeamRepository.updateTeams(id, cleanedConfig.teams).bind()
        syncConfigEventsRepository.updateEvents(id, cleanedConfig.events).bind()
        syncConfigSportsRepository.updateSports(id, cleanedConfig.sports).bind()
        syncConfigById(id, userId).bind()
    }

    private fun removeDuplicates(syncConfig: SyncConfigDto): SyncConfigDto {
        val events = syncConfig.events.distinctBy { it.id }
        val teams = syncConfig.teams.distinctBy { it.id }
        val sports = syncConfig.sports.distinct()
        return syncConfig.copy(events = events, teams = teams, sports = sports)
    }

    fun deleteSyncConfig(id: UUID, userId: UUID): SynciEither<Int> =
        syncConfigBelongsToUser(id, userId).flatMap { syncConfig ->
            syncConfigRepository.deleteById(syncConfig.id)
        }

    private fun syncConfigBelongsToUser(syncConfigId: UUID, userId: UUID): Either<SynciError, SyncConfigsTable> =
        either {
            val configs = syncConfigRepository.findAllSyncConfigsByUser(userId).bind()
            val syncConfig = configs.find { it.id.equals(syncConfigId) }
            ensure(syncConfig != null) {
                ElementNotFound("Could not find sync config with id $syncConfigId, for user $userId")
            }
            syncConfig
        }
}
