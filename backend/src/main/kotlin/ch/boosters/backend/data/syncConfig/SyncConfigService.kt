package ch.boosters.backend.data.syncConfig

import org.springframework.stereotype.Service

@Service
class SyncConfigService(private val syncConfigRepository: SyncConfigRepository) {

    fun getAllSyncConfigs(): List<SyncConfig> {
        return syncConfigRepository.getAllSyncConfigs()
    }
}