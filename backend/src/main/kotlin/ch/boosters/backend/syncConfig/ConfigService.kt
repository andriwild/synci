package ch.boosters.backend.syncConfig

import org.springframework.stereotype.Service

@Service
class ConfigService {

    fun createConfig(): String {
        return "create"
    }

    fun editConfig(): String {
        return "edit"
    }
}