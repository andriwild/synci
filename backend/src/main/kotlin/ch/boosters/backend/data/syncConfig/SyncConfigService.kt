package ch.boosters.backend.data.syncConfig

import org.springframework.stereotype.Service
import java.util.*

@Service
class SyncConfigService(private val syncConfigRepository: SyncConfigRepository) {

    fun getAllSyncConfigs(): List<SyncConfig> {
        return syncConfigRepository.getAllSyncConfigs()
    }

    fun updateSyncConfig(id: UUID, syncConfig: SyncConfig): SyncConfig {
        return syncConfigRepository.updateSyncConfig(id, syncConfig)
    }
}