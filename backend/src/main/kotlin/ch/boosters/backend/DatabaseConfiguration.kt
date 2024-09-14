package ch.boosters.backend

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.context.annotation.Configuration
import com.zaxxer.hikari.HikariConfig;


@Configuration
@ConfigurationProperties("ch.boosters.db")
class DatabaseConfiguration: HikariConfig()

