package ch.boosters.backend.data.user

import ch.boosters.backend.data.user.model.User
import ch.boosters.data.Tables.USERS_TABLE
import org.jooq.DSLContext
import org.springframework.stereotype.Repository

@Repository
class UserRepository(private val dslContext: DSLContext) {

    fun findUserByEmail(email: String): User? {
        return dslContext.select().from(USERS_TABLE).where(USERS_TABLE.E_MAIL.eq(email)).fetchOne()?.let {
            User(
                email = it[USERS_TABLE.E_MAIL],
                name = it[USERS_TABLE.NAME],
            )

        }
    }

    fun createUser(firstName: String, email: String) {
        dslContext.insertInto(USERS_TABLE)
            .set(USERS_TABLE.NAME, firstName)
            .set(USERS_TABLE.E_MAIL, email)
            .execute()
    }

    fun updateUser(user: User) {
        dslContext.update(USERS_TABLE)
            .set(USERS_TABLE.NAME, user.name)
            .where(USERS_TABLE.E_MAIL.eq(user.email))
            .execute()
    }
}
