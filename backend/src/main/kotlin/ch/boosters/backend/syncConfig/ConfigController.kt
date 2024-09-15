package ch.boosters.backend.syncConfig

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/syncconfig")
class ConfigController(private val syncConfigService: SyncConfigService) {

        @GetMapping("/list")
        fun listConfig(): List<SyncConfig> {
            return syncConfigService
        }
}