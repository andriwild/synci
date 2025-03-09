package ch.boosters.backend.data.syncConfig.syncConfigSports

import arrow.core.raise.either
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.Tables.*
import ch.boosters.data.tables.pojos.EventsTable
import ch.boosters.data.tables.pojos.SportsTable
import org.jooq.DSLContext
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class SyncConfigSportsRepository(
    private val dsl: JooqEitherDsl
) {

    fun getSportsIdBySyncConfigId(id: UUID): SynciEither<List<SportsTable>> =
        dsl { it: DSLContext ->
            it
                .select(SPORTS_TABLE.asterisk())
                .from(SPORTS_TABLE)
                .join(SYNC_CONFIGS_SPORTS_TABLE)
                .on(SYNC_CONFIGS_SPORTS_TABLE.SPORT_ID.eq(SPORTS_TABLE.ID))
                .where(SYNC_CONFIGS_SPORTS_TABLE.SYNC_CONFIG_ID.eq(id))
                .fetchInto(SportsTable::class.java)
        }

    fun updateSports(configId: UUID, sports: List<UUID>): SynciEither<List<UUID>> = either {
        dsl {
            it.delete(SYNC_CONFIGS_SPORTS_TABLE)
                .where(SYNC_CONFIGS_SPORTS_TABLE.SYNC_CONFIG_ID.eq(configId))
                .execute()
        }.bind()
        addSports(configId, sports).bind()
    }

    fun addSports(configId: UUID, sports: List<UUID>): SynciEither<List<UUID>> = either {
        sports.map { sportId ->
            dsl {
                it.insertInto(SYNC_CONFIGS_SPORTS_TABLE)
                    .columns(
                        SYNC_CONFIGS_SPORTS_TABLE.SYNC_CONFIG_ID,
                        SYNC_CONFIGS_SPORTS_TABLE.SPORT_ID
                    )
                    .values(configId, sportId)
                    .execute()
            }
        }.filter { it.isRight() }
            .bindAll()
        sports
    }
}