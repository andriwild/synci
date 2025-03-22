package ch.boosters.backend.data.syncConfig

import arrow.core.raise.either
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.data.syncConfig.model.SyncConfigDto
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.tables.SyncConfigsTable.Companion.SYNC_CONFIGS_TABLE
import ch.boosters.data.tables.SyncConfigsUsersTable.Companion.SYNC_CONFIGS_USERS_TABLE
import ch.boosters.data.tables.pojos.SyncConfigsTable
import org.jooq.DSLContext
import org.jooq.impl.DSL
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class SyncConfigRepository(private val dsl: JooqEitherDsl) {

    fun createSyncConfig(syncConfig: SyncConfigDto, userId: UUID): SynciEither<UUID> = either {
        val syncConfigId = UUID.randomUUID()
        dsl { it: DSLContext ->
            it.transaction { config ->
                val tx = DSL.using(config)
                tx.insertInto(SYNC_CONFIGS_TABLE)
                    .columns(SYNC_CONFIGS_TABLE.ID, SYNC_CONFIGS_TABLE.NAME)
                    .values(syncConfigId, syncConfig.name)
                    .execute()

                tx.insertInto(SYNC_CONFIGS_USERS_TABLE)
                    .columns(
                        SYNC_CONFIGS_USERS_TABLE.ID,
                        SYNC_CONFIGS_USERS_TABLE.USER_ID,
                        SYNC_CONFIGS_USERS_TABLE.SYNC_CONFIG_ID
                    )
                    .values(UUID.randomUUID(), userId, syncConfigId)
                    .execute()
            }
        }
        syncConfigId
    }

    fun updateSyncConfig(id: UUID, syncConfig: SyncConfigDto): SynciEither<SyncConfigDto> = either {
        dsl {
            it.update(SYNC_CONFIGS_TABLE)
                .set(SYNC_CONFIGS_TABLE.NAME, syncConfig.name)
                .where(SYNC_CONFIGS_TABLE.ID.eq(id))
                .execute()
        }.bind()
        syncConfig
    }

    fun deleteById(id: UUID): SynciEither<Int> =
        dsl {
            it.delete(SYNC_CONFIGS_TABLE)
                .where(SYNC_CONFIGS_TABLE.ID.eq(id))
                .execute()
        }

    fun findAllSyncConfigsByUser(userId: UUID): SynciEither<List<SyncConfigsTable>> =
        dsl { it: DSLContext ->
            it
                .select(SYNC_CONFIGS_TABLE.asterisk()).from(SYNC_CONFIGS_TABLE)
                .join(SYNC_CONFIGS_USERS_TABLE)
                .on(SYNC_CONFIGS_USERS_TABLE.SYNC_CONFIG_ID.eq(SYNC_CONFIGS_TABLE.ID))
                .where(SYNC_CONFIGS_USERS_TABLE.USER_ID.eq(userId))
                .fetchInto(SyncConfigsTable::class.java)
        }
}