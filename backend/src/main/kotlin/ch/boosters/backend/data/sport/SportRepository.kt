package ch.boosters.backend.data.sport

import ch.boosters.data.Tables.SPORTS_TABLE
import org.jooq.DSLContext
import org.jooq.impl.DSL.*
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class SportRepository(
    private val dsl: DSLContext
) {

   private val skiAlpineRootName = "SKI_ALPINE"

    fun getSkiRoot(): Sport? {
        return getSportByName(skiAlpineRootName)
    }

    fun getSportByName(name: String): Sport? {
        return dsl
            .select(SPORTS_TABLE)
            .from(SPORTS_TABLE)
            .where(SPORTS_TABLE.NAME.eq(name))
            .fetchOneInto(Sport::class.java)
    }

    fun getSportById(id: UUID): Sport? {
        return dsl
            .select(SPORTS_TABLE)
            .from(SPORTS_TABLE)
            .where(SPORTS_TABLE.ID.eq(id))
            .fetchOneInto(Sport::class.java)
    }

    fun getSubcategoriesById(rootId: UUID): List<Sport> {
        val descendants = name("descendants").fields("id", "name", "parent_id").`as`(
            select(SPORTS_TABLE.ID, SPORTS_TABLE.NAME, SPORTS_TABLE.PARENT_ID)
                .from(SPORTS_TABLE)
                .where(SPORTS_TABLE.ID.eq(rootId))
                .unionAll(
                    select(SPORTS_TABLE.ID, SPORTS_TABLE.NAME, SPORTS_TABLE.PARENT_ID)
                        .from(SPORTS_TABLE)
                        .join(table(name("descendants")))
                        .on(SPORTS_TABLE.PARENT_ID.eq(field(name("descendants", "id"), UUID::class.java)))
                )
        )

        val sportsList: List<Sport> = dsl
            .withRecursive(descendants)
            .selectFrom(descendants)
            .where(field(name("descendants", "id"), UUID::class.java).ne(rootId))
            .fetchInto(Sport::class.java)

        val rootSport = getSportById(rootId)
        return if (rootSport == null) sportsList else sportsList.plus(rootSport)
    }
}