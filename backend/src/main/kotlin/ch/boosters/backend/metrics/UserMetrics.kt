package ch.boosters.backend.metrics

import ch.boosters.data.tables.references.USERS_TABLE
import io.micrometer.core.instrument.Gauge
import io.micrometer.core.instrument.MeterRegistry
import org.jooq.DSLContext
import org.springframework.stereotype.Component

@Component
class UserMetrics(
    private val dsl: DSLContext,
    registry: MeterRegistry
) {
    init {
        Gauge.builder("synci.users.total") {
            dsl.fetchCount(USERS_TABLE)
        }
        .description("Total number of users in users_table")
        .register(registry)
    }
}
