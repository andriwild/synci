package ch.boosters.backend.data.syncConfig

import arrow.core.raise.either
import ch.boosters.backend.data.syncConfig.model.SyncConfigDto
import ch.boosters.backend.data.syncConfig.syncConfigEvents.SyncConfigEventsRepository
import ch.boosters.backend.data.syncConfig.syncConfigSports.SyncConfigSportsRepository
import ch.boosters.backend.data.syncConfig.syncConfigTeam.SyncConfigTeamRepository
import ch.boosters.backend.errorhandling.SynciEither
import org.springframework.stereotype.Service
import java.util.UUID

@Service
class SyncConfigService(
    private val syncConfigRepository: SyncConfigRepository,
    private val syncConfigTeamRepository: SyncConfigTeamRepository,
    private val syncConfigSportsRepository: SyncConfigSportsRepository,
    private val syncConfigEventsRepository: SyncConfigEventsRepository
) {

    fun createSyncConfig(syncConfig: SyncConfigDto): SynciEither<SyncConfig> = either {
        val id = syncConfigRepository.createSyncConfig(syncConfig).bind()
        syncConfigTeamRepository.addTeams(id, syncConfig.teams).bind()
        syncConfigSportsRepository.addSports(id, syncConfig.sports).bind()
        syncConfigEventsRepository.addEvents(id, syncConfig.events).bind()
        syncConfigById(id).bind()
    }

    fun allSyncConfigs(): SynciEither<List<SyncConfig>> = either {
        val configs = syncConfigRepository.findAllSyncConfigs().bind()
        configs.map { syncConfigById(it.id) }.bindAll()
    }

    fun syncConfigById(id: UUID): SynciEither<SyncConfig> = either {
        val syncConfig       = syncConfigRepository.syncConfigById(id).bind()
        val sportsOfConfig   = syncConfigSportsRepository.getSportsIdBySyncConfigId(id).bind()
        val teamsOfConfig    = syncConfigTeamRepository.getTeamBySyncConfigId(id).bind()
        val eventIdsInConfig = syncConfigEventsRepository.getEventsIdsBySyncConfigId(id).bind()

        SyncConfig(
            id = id,
            name = syncConfig.name,
            teams = teamsOfConfig,
            sports = sportsOfConfig,
            events = eventIdsInConfig,
        )
    }

    fun updateSyncConfig(id: UUID, syncConfig: SyncConfigDto): SynciEither<SyncConfig> = either {
        syncConfigRepository.updateSyncConfig(id, syncConfig).bind()
        syncConfigTeamRepository.updateTeams(id, syncConfig.teams).bind()
        syncConfigSportsRepository.updateSports(id, syncConfig.sports).bind()
        syncConfigById(id).bind()
    }

    fun deleteSyncConfig(id: UUID): SynciEither<Int> =
        syncConfigRepository.deleteById(id)
}
