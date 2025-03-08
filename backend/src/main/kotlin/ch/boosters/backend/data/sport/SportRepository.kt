package ch.boosters.backend.data.sport

import ch.boosters.data.Tables
import ch.boosters.data.tables.pojos.SportsTable
import org.jooq.DSLContext
import org.jooq.impl.DSL.*
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class SportRepository(
    private val dsl: DSLContext
) {

    private val skiAlpineRootName = "SKI_ALPINE"
    private val sports = Tables.SPORTS_TABLE

    fun getSportById(id: UUID): SportsTable? {
        return dsl
            .select(sports)
            .from(sports)
            .where(sports.ID.eq(id))
            .fetchOneInto(SportsTable::class.java)
    }

    fun getSubcategoriesById(rootId: UUID): List<SportsTable> {
        val descendants = name("descendants").fields("id", "name", "parent_id").`as`(
            select(sports.ID, sports.NAME, sports.PARENT_ID)
                .from(sports)
                .where(sports.ID.eq(rootId))
                .unionAll(
                    select(sports.ID, sports.NAME, sports.PARENT_ID)
                        .from(sports)
                        .join(table(name("descendants")))
                        .on(sports.PARENT_ID.eq(field(name("descendants", "id"), UUID::class.java)))
                )
        )

        val sportsList: List<SportsTable> = dsl
            .withRecursive(descendants)
            .selectFrom(descendants)
            .where(field(name("descendants", "id"), UUID::class.java).ne(rootId))
            .fetchInto(SportsTable::class.java)

        val rootSport = getSportById(rootId)
        return if (rootSport == null) sportsList else sportsList.plus(rootSport)
    }

    fun allSports() : List<SportsTable> {
        val sports = dsl.selectFrom(sports).fetch().into(SportsTable::class.java)
        return sports
    }
}