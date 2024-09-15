package ch.boosters.backend.syncConfig

import org.springframework.stereotype.Repository

@Repository
class SyncConfigRepository {

    fun getAllSyncConfigs(): List<SyncConfig> {
        return emptyList()
    }
}