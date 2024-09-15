package ch.boosters.backend.data.syncConfig

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
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
}