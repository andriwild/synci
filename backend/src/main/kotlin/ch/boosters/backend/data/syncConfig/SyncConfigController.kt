package ch.boosters.backend.data.syncConfig

import ch.boosters.backend.errorhandling.SynciEither
import org.springframework.web.bind.annotation.*
import java.util.UUID

@RestController
@RequestMapping("/syncconfig")
class SyncConfigController(private val syncConfigService: SyncConfigService) {

    @GetMapping("/list")
    fun listConfig(): SynciEither<List<SyncConfig>> =
        syncConfigService.getAllSyncConfigs()

    @GetMapping("/{id}")
    fun newConfig(@PathVariable id: UUID): SynciEither<SyncConfig> =
        syncConfigService.getSyncConfig(id)

    @PutMapping("/{id}")
    fun updateConfig(@PathVariable id: UUID, @RequestBody syncConfig: SyncConfig): SynciEither<Unit> =
        syncConfigService.updateSyncConfig(id, syncConfig)

    @PostMapping("/new")
    fun createConfig(@RequestBody syncConfig: SyncConfig): SynciEither<UUID> =
        syncConfigService.createSyncConfig(syncConfig)

    @DeleteMapping("/{id}")
    fun deleteConfig(@PathVariable id: UUID): SynciEither<Int> =
        syncConfigService.deleteSyncConfig(id)
}
