package ch.boosters.backend.data.syncConfig

import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.*
import java.util.UUID

@RestController
@RequestMapping("/syncconfig")
@PreAuthorize("isAuthenticated()")
class SyncConfigController(private val syncConfigService: SyncConfigService) {

    @GetMapping("/list")
    fun listConfig(): List<SyncConfig> {
        return syncConfigService.getAllSyncConfigs()
    }

    @GetMapping("/{id}")
    fun newConfig(@PathVariable id: UUID): SyncConfig? {
        return syncConfigService.getSyncConfig(id)
    }

    @PutMapping("/{id}")
    fun updateConfig(@PathVariable id: UUID, @RequestBody syncConfig: SyncConfig) {
        syncConfigService.updateSyncConfig(id, syncConfig)
    }

    @PostMapping("/new")
    fun createConfig(@RequestBody syncConfig: SyncConfig) {
        syncConfigService.createSyncConfig(syncConfig)
    }

    @DeleteMapping("/{id}")
    fun deleteConfig(@PathVariable id: UUID): Int {
        return syncConfigService.deleteSyncConfig(id)
    }
}
