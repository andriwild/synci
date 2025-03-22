package ch.boosters.backend.data.syncConfig

import arrow.core.Either
import arrow.core.flatMap
import arrow.core.raise.either
import arrow.core.raise.ensure
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
    private val syncConfigEventsRepository: SyncConfigEventsRepository
) {

    fun createSyncConfig(syncConfig: SyncConfigDto, userId: UUID): SynciEither<SyncConfig> = either {
        val id = syncConfigRepository.createSyncConfig(syncConfig, userId).bind()
        syncConfigTeamRepository.addTeams(id, syncConfig.teams).bind()
        syncConfigSportsRepository.addSports(id, syncConfig.sports).bind()
        syncConfigEventsRepository.addEvents(id, syncConfig.events).bind()
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

        SyncConfig(
            id = id,
            name = syncConfig.name,
            teams = teamsOfConfig,
            sports = sportsOfConfig,
            events = eventIdsInConfig,
        )
    }

    fun updateSyncConfig(id: UUID, syncConfig: SyncConfigDto, userId: UUID): SynciEither<SyncConfig> = either {
        syncConfigRepository.updateSyncConfig(id, syncConfig).bind()
        syncConfigTeamRepository.updateTeams(id, syncConfig.teams).bind()
        syncConfigEventsRepository.updateEvents(id, syncConfig.events).bind()
        syncConfigSportsRepository.updateSports(id, syncConfig.sports).bind()
        syncConfigById(id, userId).bind()
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
