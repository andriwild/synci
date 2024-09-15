package ch.boosters.backend.syncConfig

import org.springframework.stereotype.Service

@Service
class SyncConfigService(private val syncConfigRepository: SyncConfigRepository) {

    fun getAllSyncConfigs(): List<SyncConfig> {
        return syncConfigRepository.getAllSyncConfigs()
    }
}