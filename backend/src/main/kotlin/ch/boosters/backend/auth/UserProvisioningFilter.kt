package ch.boosters.backend.auth
import ch.boosters.backend.data.syncConfig.SyncConfigService
import ch.boosters.backend.data.syncConfig.model.SyncConfigDto
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
    private val dsl: DSLContext,
    private val syncConfigService: SyncConfigService
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
                
                val defaultSyncConfig = SyncConfigDto(
                    id = null,
                    name = "Standard-Abo",
                    events = emptyList(),
                    teams = emptyList(),
                    sports = emptyList()
                )
                
                syncConfigService.createSyncConfig(defaultSyncConfig, userId)
                    .fold(
                        { error -> logger.error("Fehler beim Erstellen der Standard-SyncConfig für Benutzer $userId: $error") },
                        { logger.info("Standard-SyncConfig erstellt für Benutzer $userId") }
                    )
            }
        }

        filterChain.doFilter(request, response)
    }
}
