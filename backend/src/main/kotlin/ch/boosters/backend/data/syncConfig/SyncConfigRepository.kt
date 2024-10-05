package ch.boosters.backend.data.syncConfig

import ch.boosters.backend.data.team.Team
import ch.boosters.data.Tables.*
import org.jooq.DSLContext
import org.springframework.stereotype.Repository
import java.util.UUID

@Repository
class SyncConfigRepository (private val dsl: DSLContext) {

    fun getById(id: UUID): SyncConfig? {
        val allConfigs = getAllSyncConfigs()
        return allConfigs.find { it.id == id }
    }

    fun createSyncConfig(syncConfig: SyncConfig): UUID {
        val uuid = UUID.randomUUID()

        val syncConfigQuery = dsl.insertInto(SYNC_CONFIGS_TABLE)
            .columns(SYNC_CONFIGS_TABLE.ID, SYNC_CONFIGS_TABLE.NAME)
            .values(uuid, syncConfig.name)

        dsl.batch(syncConfigQuery).execute()
        return uuid
    }

    fun getAllSyncConfigs(): List<SyncConfig> {
        //TODO get list of syncs and each syncs has a list of teams
        // TODO: add sync configs without relations (should also be visible in the UI)

        return dsl.select(
            SYNC_CONFIGS_TABLE.NAME,
            SYNC_CONFIGS_TABLE.ID,
            TEAMS_TABLE.NAME,
            TEAMS_TABLE.ID,
            TEAMS_TABLE.SOURCE_ID
        )
            .from(SYNC_CONFIGS_TABLE)
            .join(SYNC_CONFIGS_TEAMS_TABLE)
            .on(
                SYNC_CONFIGS_TABLE.ID.eq(SYNC_CONFIGS_TEAMS_TABLE.SYNC_CONFIG_ID)
            )
            .join(TEAMS_TABLE)
            .on(SYNC_CONFIGS_TEAMS_TABLE.TEAM_ID.eq(TEAMS_TABLE.ID))
            .fetch().map {
                println(it)
                SyncConfig(
                    it.getValue(SYNC_CONFIGS_TABLE.ID),
                    it.getValue(SYNC_CONFIGS_TABLE.NAME),
                    listOf(
                        Team(
                            it.getValue(TEAMS_TABLE.ID),
                            it.getValue(TEAMS_TABLE.SOURCE_ID),
                            it.getValue(TEAMS_TABLE.NAME)
                        )
                    )
                )
            }.groupBy {
                it.id
            }.map { it ->
                SyncConfig(it.key, it.value.first().name, it.value.map { it.teams.first() })
            }
    }


//    fun getSyncConfigById(id: UUID): SyncConfig {
//        return dsl.select().from(SYNC_CONFIGS_TABLE).where(SYNC_CONFIGS_TABLE.ID.eq(id)).fetch().map {
//            SyncConfig(it.getValue(SYNC_CONFIGS_TABLE.ID), it.getValue(SYNC_CONFIGS_TABLE.ICAL_URL))
//        }.first()
//    }
    fun updateSyncConfig(id: UUID, syncConfig: SyncConfig): SyncConfig {
        dsl.update(SYNC_CONFIGS_TABLE)
            .set(SYNC_CONFIGS_TABLE.NAME, syncConfig.name)
            .where(SYNC_CONFIGS_TABLE.ID.eq(id))
            .execute()

        return syncConfig
    }

    fun deleteById(id: UUID) : Int {
        return dsl.delete(SYNC_CONFIGS_TABLE)
            .where(SYNC_CONFIGS_TABLE.ID.eq(id))
            .execute()
    }
}
