package ch.boosters.backend.data.syncConfig

import org.jooq.DSLContext
import ch.boosters.data.Tables.SYNC_CONFIGS_TABLE
import org.springframework.stereotype.Repository

@Repository
class SyncConfigRepository (private val dslContext: DSLContext) {

    fun getAllSyncConfigs(): List<SyncConfig> {
        return dslContext.select().from(SYNC_CONFIGS_TABLE).fetch().map {
            SyncConfig(it.getValue(SYNC_CONFIGS_TABLE.ID), it.getValue(SYNC_CONFIGS_TABLE.URL))
        }
    }
}