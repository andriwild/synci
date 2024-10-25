package ch.boosters.backend.data.syncConfig

import ch.boosters.backend.data.sport.Sport
import ch.boosters.backend.data.team.Team
import ch.boosters.data.Tables.*
import org.jooq.DSLContext
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class SyncConfigRepository (private val dsl: DSLContext) {

    fun getById(id: UUID): SyncConfig? {
        val teamConfigs = getTeamSyncConfigs()
        val sportConfigs = getSportSyncConfigs()
        val allConfigs = mergeConfigs(teamConfigs, sportConfigs)
        return allConfigs.first { it.id == id }
    }

    fun createSyncConfig(syncConfig: SyncConfig): UUID {
        val uuid = UUID.randomUUID()

        dsl.insertInto(SYNC_CONFIGS_TABLE)
            .columns(SYNC_CONFIGS_TABLE.ID, SYNC_CONFIGS_TABLE.NAME)
            .values(uuid, syncConfig.name)
            .execute()
        return uuid
    }

   fun getAllSyncConfigs(): List<SyncConfig> {
       val teamConfigs = getTeamSyncConfigs()
       val sportConfigs = getSportSyncConfigs()

       return mergeConfigs(teamConfigs, sportConfigs)
   }

    private fun mergeConfigs(
        teamConfigs: List<SyncConfig>,
        sportConfigs: List<SyncConfig>
    ) = (teamConfigs + sportConfigs).groupBy { it.id }
        .map { it ->
            SyncConfig(
                it.key,
                it.value.first().name,
                it.value.flatMap { it.teams },
                it.value.flatMap { it.sports },
            )
        }

    fun getTeamSyncConfigs(): List<SyncConfig> {
        val syncConfigId = "sync_config_id"
        val syncConfigName = "sync_config_name"
        val teamId = "team_id"
        val teamName = "team_name"
        val teamSourceId = "team_source_id"

        val records = dsl.select(
            SYNC_CONFIGS_TABLE.ID.`as`(syncConfigId),
            SYNC_CONFIGS_TABLE.NAME.`as`(syncConfigName),
            TEAMS_TABLE.ID.`as`(teamId),
            TEAMS_TABLE.NAME.`as`(teamName),
            TEAMS_TABLE.SOURCE_ID.`as`(teamSourceId)
        )
            .from(SYNC_CONFIGS_TABLE)
            .leftJoin(SYNC_CONFIGS_TEAMS_TABLE)
            .on(SYNC_CONFIGS_TABLE.ID.eq(SYNC_CONFIGS_TEAMS_TABLE.SYNC_CONFIG_ID))
            .leftJoin(TEAMS_TABLE)
            .on(SYNC_CONFIGS_TEAMS_TABLE.TEAM_ID.eq(TEAMS_TABLE.ID))
            .fetch()

        return records
            .groupBy { it.get(syncConfigId, UUID::class.java) }
            .map { (configId, group) ->
                val configName = group.first().get(syncConfigName, String::class.java) ?: "Unnamed"

                val teams = group.mapNotNull { record ->
                    val id = record.get(teamId, Int::class.java)
                    val name = record.get(teamName, String::class.java)
                    val sourceId = record.get(teamSourceId, Int::class.java)
                    if(id != null && name != null && sourceId != null) {
                        Team(
                            id = id.toString(),
                            name = name,
                            source = sourceId
                        )
                    } else null
                }.distinct()

                SyncConfig(
                    id = configId,
                    name = configName,
                    teams = teams,
                    sports = emptyList()
                )
            }
    }

    fun getSportSyncConfigs(): List<SyncConfig> {
        val syncConfigId = "sync_config_id"
        val syncConfigName = "sync_config_name"
        val sportId = "sport_id"
        val sportName = "sport_name"
        val sportParentId = "sport_parent_id"

        val records = dsl.select(
            SYNC_CONFIGS_TABLE.ID.`as`(syncConfigId),
            SYNC_CONFIGS_TABLE.NAME.`as`(syncConfigName),
            SPORTS_TABLE.ID.`as`(sportId),
            SPORTS_TABLE.NAME.`as`(sportName),
            SPORTS_TABLE.PARENT_ID.`as`(sportParentId)
        )
            .from(SYNC_CONFIGS_TABLE)
            .leftJoin(SYNC_CONFIGS_SPORTS_TABLE)
            .on(SYNC_CONFIGS_TABLE.ID.eq(SYNC_CONFIGS_SPORTS_TABLE.SYNC_CONFIG_ID))
            .leftJoin(SPORTS_TABLE)
            .on(SYNC_CONFIGS_SPORTS_TABLE.SPORT_ID.eq(SPORTS_TABLE.ID))
            .fetch()

        return records
            .groupBy { it.get(syncConfigId, UUID::class.java) }
            .map { (configId, group) ->
                val configName = group.first().get(syncConfigName, String::class.java) ?: "Unnamed"

                val sports = group.mapNotNull { record ->
                    val id = record.get(sportId, UUID::class.java)
                    val name = record.get(sportName, String::class.java)
                    val parentId = record.get(sportParentId, UUID::class.java)
                    if (id != null && name != null && parentId != null) {
                        Sport(
                            id = id,
                            name = name,
                            parentId = parentId
                        )
                    } else null
                }.distinct()

                SyncConfig(
                    id = configId,
                    name = configName,
                    teams = emptyList(),
                    sports = sports
                )
            }
    }

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