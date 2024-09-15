package ch.boosters.backend.data.user

import ch.boosters.backend.data.user.model.User
import ch.boosters.data.Tables.USER
import org.jooq.DSLContext
import org.springframework.stereotype.Repository

@Repository
class UserRepository(private val dslContext: DSLContext) {

    fun findUserByEmail(email: String): User? {
        return dslContext.select().from(USER).where(USER.E_MAIL.eq(email)).fetchOne()?.let {
            User(
                email = it[USER.E_MAIL],
                name = it[USER.NAME],
            )

        }
    }

    fun createUser(firstName: String, email: String) {
        dslContext.insertInto(USER)
            .set(USER.NAME, firstName)
            .set(USER.E_MAIL, email)
            .execute()
    }

    fun updateUser(user: User) {
        dslContext.update(USER)
            .set(USER.NAME, user.name)
            .where(USER.E_MAIL.eq(user.email))
            .execute()
    }
}
