package ch.boosters.backend.data.syncConfig

import org.jooq.DSLContext
import ch.boosters.data.Tables.SYNC_CONFIGS_TABLE
import org.springframework.stereotype.Repository
import java.util.UUID

@Repository
class SyncConfigRepository (private val dslContext: DSLContext) {

    fun getAllSyncConfigs(): List<SyncConfig> {
        //TODO get list of syncs and each syncs has a list of teams

        return dslContext.select().from(SYNC_CONFIGS_TABLE).fetch().map {
            SyncConfig(it.getValue(SYNC_CONFIGS_TABLE.ID), it.getValue(SYNC_CONFIGS_TABLE.ICAL_URL))
        }

    }
    fun getSyncConfigById(id: UUID): SyncConfig {
        return dslContext.select().from(SYNC_CONFIGS_TABLE).where(SYNC_CONFIGS_TABLE.ID.eq(id)).fetch().map {
            SyncConfig(it.getValue(SYNC_CONFIGS_TABLE.ID), it.getValue(SYNC_CONFIGS_TABLE.ICAL_URL))
        }.first()
    }
    fun updateSyncConfig(id: UUID, syncConfig: SyncConfig): SyncConfig {
        dslContext.update(SYNC_CONFIGS_TABLE).set(SYNC_CONFIGS_TABLE.ICAL_URL, syncConfig.url).where(SYNC_CONFIGS_TABLE.ID.eq(id)).execute()
        return syncConfig
    }
}