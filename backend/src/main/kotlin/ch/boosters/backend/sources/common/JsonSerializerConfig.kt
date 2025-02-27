package ch.boosters.backend.sources.common

import kotlinx.serialization.json.Json
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class JsonSerializerConfig {

    @Bean
    fun jsonSerializer(): Json = Json { ignoreUnknownKeys = true }
}