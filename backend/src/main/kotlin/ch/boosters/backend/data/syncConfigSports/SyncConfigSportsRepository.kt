package ch.boosters.backend.data.syncConfigSports

import arrow.core.raise.either
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.Tables.*
import ch.boosters.data.tables.pojos.SportsTable
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class SyncConfigSportsRepository(
    private val dsl: JooqEitherDsl
) {
    fun updateSports(configId: UUID, sports: List<SportsTable>): SynciEither<List<SportsTable>> = either {
        dsl {
            it.delete(SYNC_CONFIGS_SPORTS_TABLE)
                .where(SYNC_CONFIGS_SPORTS_TABLE.SYNC_CONFIG_ID.eq(configId))
                .execute()
        }.bind()
        addSports(configId, sports).bind()
    }

    fun addSports(configId: UUID, sports: List<SportsTable>): SynciEither<List<SportsTable>> = either {
        sports.map { sport ->
            dsl {
                it.insertInto(SYNC_CONFIGS_SPORTS_TABLE)
                    .columns(
                        SYNC_CONFIGS_SPORTS_TABLE.SYNC_CONFIG_ID,
                        SYNC_CONFIGS_SPORTS_TABLE.SPORT_ID
                    )
                    .values(configId, sport.id)
                    .execute()
            }
        }.filter { it.isRight() }
            .bindAll()
        sports
    }
}