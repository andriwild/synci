package ch.boosters.backend.data.configuration

import com.zaxxer.hikari.HikariDataSource
import org.jooq.DSLContext
import org.jooq.SQLDialect
import org.jooq.impl.DSL
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class JooqDslContextConfiguration(private val databaseConfiguration: DatabaseConfiguration) {
   private var dataSource: HikariDataSource? = null

    @Bean("datasource")
    open fun getDatasource(): HikariDataSource  {
        if (dataSource == null) {
            dataSource = HikariDataSource(databaseConfiguration)
        }
        return dataSource as HikariDataSource
    }


    @Bean("dslContext")
    fun getDslContext(): DSLContext {
        return DSL.using(getDatasource(), SQLDialect.POSTGRES);
    }

}