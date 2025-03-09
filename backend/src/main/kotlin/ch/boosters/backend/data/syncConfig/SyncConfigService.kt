package ch.boosters.backend.data.syncConfig

import arrow.core.raise.either
import ch.boosters.backend.data.syncConfigSports.SyncConfigSportsRepository
import ch.boosters.backend.data.syncConfigTeam.SyncConfigTeamRepository
import ch.boosters.backend.errorhandling.SynciEither
import org.springframework.stereotype.Service
import java.util.*

@Service
class SyncConfigService(
    private val syncConfigRepository: SyncConfigRepository,
    private val syncConfigTeamRepository: SyncConfigTeamRepository,
    private val syncConfigSportsRepository: SyncConfigSportsRepository
) {

    fun createSyncConfig(syncConfig: SyncConfig): SynciEither<UUID> = either {
        val id = syncConfigRepository.createSyncConfig(syncConfig).bind()
        syncConfigTeamRepository.addTeams(id, syncConfig.teams).bind()
        syncConfigSportsRepository.addSports(id, syncConfig.sports).bind()
        id
    }

    fun getSyncConfig(id: UUID): SynciEither<SyncConfig> =
       syncConfigRepository.getById(id)

    fun getAllSyncConfigs(): SynciEither<List<SyncConfig>> =
        syncConfigRepository.getAllSyncConfigs()

    fun updateSyncConfig(id: UUID, syncConfig: SyncConfig): SynciEither<Unit> = either {
        syncConfigRepository.updateSyncConfig(id, syncConfig).bind()
        syncConfigTeamRepository.updateTeams(id, syncConfig.teams).bind()
        syncConfigSportsRepository.updateSports(id, syncConfig.sports).bind()
    }

    fun deleteSyncConfig(id: UUID): SynciEither<Int> =
        syncConfigRepository.deleteById(id)
}
