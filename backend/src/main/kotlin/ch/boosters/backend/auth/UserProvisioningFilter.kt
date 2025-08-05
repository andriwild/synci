package ch.boosters.backend.auth
import ch.boosters.data.tables.references.USERS_TABLE
import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.jooq.DSLContext
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Component
import org.springframework.web.filter.OncePerRequestFilter
import java.util.*

@Component
class UserProvisioningFilter(
    private val dsl: DSLContext
) : OncePerRequestFilter() {

    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        filterChain: FilterChain
    ) {
        val authentication = SecurityContextHolder.getContext().authentication
        val jwt = authentication?.principal as? Jwt

        if (jwt != null) {
            val auth0Id = jwt.subject
            val email = jwt.getClaimAsString("email")
            val name = jwt.getClaimAsString("name")

            val exists = dsl.fetchExists(
                dsl.selectFrom(USERS_TABLE)
                    .where(USERS_TABLE.AUTH0_ID.eq(auth0Id))
            )

            if (!exists) {
                val userId = UUID.randomUUID()
                dsl.insertInto(USERS_TABLE)
                    .set(USERS_TABLE.ID, userId)
                    .set(USERS_TABLE.AUTH0_ID, auth0Id)
                    .set(USERS_TABLE.EMAIL, email)
                    .set(USERS_TABLE.NAME, name)
                    .execute()
                logger.info("Neuer Benutzer angelegt: $auth0Id ($email)")
            }
        }

        filterChain.doFilter(request, response)
    }
}
