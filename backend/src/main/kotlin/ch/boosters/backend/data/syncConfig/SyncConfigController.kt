package ch.boosters.backend.data.syncConfig

import ch.boosters.backend.data.syncConfig.model.SyncConfigDto
import ch.boosters.backend.errorhandling.SynciEither
import org.springframework.web.bind.annotation.*
import java.util.UUID

@RestController
@RequestMapping("/syncconfig")
class SyncConfigController(private val syncConfigService: SyncConfigService) {

    @GetMapping("/{id}")
    fun getConfig(@PathVariable id: UUID): SynciEither<SyncConfig> =
        syncConfigService.getSyncConfig(id)

    @PutMapping("/{id}")
    fun updateConfig(@PathVariable id: UUID, @RequestBody syncConfig: SyncConfigDto): SynciEither<Unit> =
        syncConfigService.updateSyncConfig(id, syncConfig)

    @PostMapping("")
    fun createConfig(@RequestBody syncConfig: SyncConfigDto): SynciEither<SyncConfig> =
        syncConfigService.createSyncConfig(syncConfig)

    @DeleteMapping("/{id}")
    fun deleteConfig(@PathVariable id: UUID): SynciEither<Int> =
        syncConfigService.deleteSyncConfig(id)
}
