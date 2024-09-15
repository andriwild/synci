package ch.boosters.backend.data.repository

import ch.boosters.data.Tables.USER
import org.jooq.DSLContext
import org.springframework.stereotype.Repository

@Repository
class UserRepository(private val dslContext: DSLContext) {

    fun allUsers(): List<String> {
        val result = dslContext.select().from(USER).fetch()

        return result.map { it.getValue(USER.LAST_NAME) }
    }
}
