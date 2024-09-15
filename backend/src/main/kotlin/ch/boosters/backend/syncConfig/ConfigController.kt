package ch.boosters.backend.syncConfig

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class ConfigController(private val configService: ConfigService) {

    @GetMapping("/config")
    fun createConfig(): String {
        return configService.createConfig()
    }

    @GetMapping("/config/id")
    fun editConfig(): String {
        return configService.editConfig()
    }
}