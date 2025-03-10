package ch.boosters.backend.data.configuration

import arrow.core.Either
import ch.boosters.backend.errorhandling.DatabaseError
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
    fun getDatasource(): HikariDataSource {
        if (dataSource == null) {
            dataSource = HikariDataSource(databaseConfiguration)
        }
        return dataSource as HikariDataSource
    }

    @Bean("jooq")
    fun getDslContext(): JooqEitherDsl {
        val dsl = DSL.using(getDatasource(), SQLDialect.POSTGRES);
        return JooqEitherDsl(dsl)
    }
}

class JooqEitherDsl(val dslContext: DSLContext) {

    operator fun <A> invoke(f: (dsl: DSLContext) -> A): Either<DatabaseError, A> {
        return Either.catch {
            f(dslContext)
        }
            .mapLeft { it ->
                DatabaseError(
                    it.message
                        ?: "An unexpected error on database level happened. This is the stack trace: ${it.stackTrace}"
                )
            }
    }
}