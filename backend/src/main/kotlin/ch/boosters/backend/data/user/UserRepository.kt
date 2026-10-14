package ch.boosters.backend.data.user

import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.tables.references.SYNC_CONFIGS_TABLE
import ch.boosters.data.tables.references.SYNC_CONFIGS_USERS_TABLE
import ch.boosters.data.tables.references.USERS_TABLE
import org.jooq.impl.DSL
import org.springframework.stereotype.Repository
import java.util.UUID

@Repository
class UserRepository(private val dsl: JooqEitherDsl) {

    // Delete the sync configs too, otherwise they stay orphaned with an active calendar URL
    fun deleteUserWithSyncConfigs(userId: UUID): SynciEither<Int> =
        dsl {
            it.transactionResult { config ->
                val tx = DSL.using(config)
                val syncConfigIds = tx
                    .select(SYNC_CONFIGS_USERS_TABLE.SYNC_CONFIG_ID)
                    .from(SYNC_CONFIGS_USERS_TABLE)
                    .where(SYNC_CONFIGS_USERS_TABLE.USER_ID.eq(userId))
                    .fetch(SYNC_CONFIGS_USERS_TABLE.SYNC_CONFIG_ID)

                val deletedSyncConfigs = tx.deleteFrom(SYNC_CONFIGS_TABLE)
                    .where(SYNC_CONFIGS_TABLE.ID.`in`(syncConfigIds))
                    .execute()

                tx.deleteFrom(USERS_TABLE)
                    .where(USERS_TABLE.ID.eq(userId))
                    .execute()

                deletedSyncConfigs
            }
        }
}
