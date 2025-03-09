package ch.boosters.backend.data.syncConfig

import arrow.core.raise.either
import arrow.core.raise.ensure
import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.data.syncConfig.model.SyncConfigDto
import ch.boosters.backend.errorhandling.DatabaseError
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.Tables.*
import ch.boosters.data.tables.pojos.SyncConfigsTable
import org.jooq.DSLContext
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class SyncConfigRepository(private val dsl: JooqEitherDsl) {

    fun syncConfigById(id: UUID): SynciEither<SyncConfigsTable> = either {
        val config = dsl { it: DSLContext ->
            it.selectFrom(SYNC_CONFIGS_TABLE)
                .where(SYNC_CONFIGS_TABLE.ID.eq(id))
                .fetchOne()?.into(SyncConfigsTable::class.java)
        }.bind()
        // TODO: use a different error type
        ensure(config != null) { DatabaseError("No config with id $id found") }
        config
    }

    fun createSyncConfig(syncConfig: SyncConfigDto): SynciEither<UUID> = either {
        val uuid = UUID.randomUUID()
        dsl {
            it.insertInto(SYNC_CONFIGS_TABLE)
                .columns(SYNC_CONFIGS_TABLE.ID, SYNC_CONFIGS_TABLE.NAME)
                .values(uuid, syncConfig.name)
                .execute()
        }
        uuid
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
}