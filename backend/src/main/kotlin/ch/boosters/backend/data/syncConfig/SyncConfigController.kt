package ch.boosters.backend.data.syncConfig

import org.springframework.web.bind.annotation.*
import java.util.UUID

@RestController
@RequestMapping("/syncconfig")
class SyncConfigController(private val syncConfigService: SyncConfigService) {

    @GetMapping("/list")
    fun listConfig(): List<SyncConfig> {
        return syncConfigService.getAllSyncConfigs()
    }

    @GetMapping("/{id}")
    fun getConfigById(@PathVariable id: UUID): SyncConfig {
        return syncConfigService.getSyncConfigById(id)
    }

    @PostMapping("/{id}")
    fun updateConfig(@PathVariable id: UUID, @RequestBody syncConfig: SyncConfig): SyncConfig {
        return syncConfigService.updateSyncConfig(id, syncConfig)
    }


}