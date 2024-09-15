package ch.boosters.backend.data.syncConfig

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/syncconfig")
class SyncConfigController(private val syncConfigService: SyncConfigService) {

        @GetMapping("/list")
        fun listConfig(): List<SyncConfig> {
            return syncConfigService.getAllSyncConfigs()
        }
}