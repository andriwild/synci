package ch.boosters.backend.data.syncConfig

import ch.boosters.backend.data.syncConfig.model.SyncConfigDto
import ch.boosters.backend.errorhandling.SynciEither
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.*
import java.util.UUID

@RestController
@RequestMapping("/syncconfigs")
@PreAuthorize("isAuthenticated()")
class SyncConfigController(private val syncConfigService: SyncConfigService) {

    @GetMapping("")
    fun getConfig(): SynciEither<List<SyncConfig>> =
        syncConfigService.allSyncConfigs()

    @GetMapping("/{id}")
    fun getConfig(@PathVariable id: UUID): SynciEither<SyncConfig> =
        syncConfigService.syncConfigById(id)

    @PutMapping("/{id}")
    fun updateConfig(@PathVariable id: UUID, @RequestBody syncConfig: SyncConfigDto): SynciEither<SyncConfig> =
        syncConfigService.updateSyncConfig(id, syncConfig)

    @PostMapping("")
    fun createConfig(@RequestBody syncConfig: SyncConfigDto): SynciEither<SyncConfig> =
        syncConfigService.createSyncConfig(syncConfig)

    @DeleteMapping("/{id}")
    fun deleteConfig(@PathVariable id: UUID): SynciEither<Int> =
        syncConfigService.deleteSyncConfig(id)
}
