package ch.boosters.backend.data.syncConfig

import ch.boosters.backend.data.syncConfigSports.SyncConfigSportsRepository
import ch.boosters.backend.data.syncConfigTeam.SyncConfigTeamRepository
import org.springframework.stereotype.Service
import java.util.*

@Service
class SyncConfigService(
    private val syncConfigRepository: SyncConfigRepository,
    private val syncConfigTeamRepository: SyncConfigTeamRepository,
    private val syncConfigSportsRepository: SyncConfigSportsRepository
) {

    fun createSyncConfig(syncConfig: SyncConfig): UUID {
        val id = syncConfigRepository.createSyncConfig(syncConfig)
        syncConfigTeamRepository.addTeams(id, syncConfig.teams)
        syncConfigSportsRepository.addSports(id, syncConfig.sports)
        return id
    }

    fun getSyncConfig(id: UUID): SyncConfig? {
       return syncConfigRepository.getById(id)
    }

    fun getAllSyncConfigs(): List<SyncConfig> {
        return syncConfigRepository.getAllSyncConfigs()
    }

    fun updateSyncConfig(id: UUID, syncConfig: SyncConfig) {
        syncConfigRepository.updateSyncConfig(id, syncConfig)
        syncConfigTeamRepository.updateTeams(id, syncConfig.teams)
        syncConfigSportsRepository.updateSports(id, syncConfig.sports)
    }

    fun deleteSyncConfig(id: UUID): Int {
        return syncConfigRepository.deleteById(id)

    }
}
