package ch.boosters.backend.data.syncConfig

import arrow.core.Either
import arrow.core.raise.either
import ch.boosters.backend.data.syncConfig.model.SyncConfigDto
import ch.boosters.backend.errorhandling.InvalidUser
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.backend.util.userId
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*
import java.util.UUID

@RestController
@RequestMapping("/syncconfigs")
@PreAuthorize("isAuthenticated()")
class SyncConfigController(private val syncConfigService: SyncConfigService) {
    @GetMapping("")
    fun getConfig(authentication: Authentication): SynciEither<List<SyncConfig>> = either {
        val userId = authentication.userId().bind()
        return syncConfigService.allSyncConfigsForUser(userId)
    }

    @GetMapping("/{id}")
    fun getConfig(@PathVariable id: UUID, authentication: Authentication): SynciEither<SyncConfig> = either {
        val userId = authentication.userId().bind()
        return syncConfigService.syncConfigById(id, userId)
    }

    @PutMapping("/{id}")
    fun updateConfig(
        @PathVariable id: UUID,
        @RequestBody syncConfig: SyncConfigDto,
        authentication: Authentication
    ): SynciEither<SyncConfig> = either {
        val userId = authentication.userId().bind()
        return syncConfigService.updateSyncConfig(id, syncConfig, userId)
    }

    @PostMapping("")
    fun createConfig(@RequestBody syncConfig: SyncConfigDto, authentication: Authentication): SynciEither<SyncConfig> =
        either {
            val userId = authentication.userId().bind()
            return syncConfigService.createSyncConfig(syncConfig, userId)
        }

    @DeleteMapping("/{id}")
    fun deleteConfig(@PathVariable id: UUID, authentication: Authentication): SynciEither<Int> = either {
        val userId = authentication.userId().bind()
        return syncConfigService.deleteSyncConfig(id, userId)
    }
}