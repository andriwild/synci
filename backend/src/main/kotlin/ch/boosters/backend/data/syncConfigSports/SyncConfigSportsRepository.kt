package ch.boosters.backend.data.syncConfigSports

import ch.boosters.backend.data.sport.Sport
import ch.boosters.data.Tables.*
import org.jooq.DSLContext
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class SyncConfigSportsRepository(
    private val dsl: DSLContext
) {
    fun updateSports(configId: UUID, sports: List<Sport>) {
        dsl.delete(SYNC_CONFIGS_SPORTS_TABLE)
            .where(SYNC_CONFIGS_SPORTS_TABLE.SYNC_CONFIG_ID.eq(configId))
            .execute()
        addSports(configId, sports)
    }

    fun addSports(configId: UUID, sports: List<Sport>) {

        sports.map { sport ->
            dsl.insertInto(SYNC_CONFIGS_SPORTS_TABLE)
                .columns(
                    SYNC_CONFIGS_SPORTS_TABLE.SYNC_CONFIG_ID,
                    SYNC_CONFIGS_SPORTS_TABLE.SPORT_ID
                )
                .values(configId, sport.id)
                .execute()
        }
    }
}
