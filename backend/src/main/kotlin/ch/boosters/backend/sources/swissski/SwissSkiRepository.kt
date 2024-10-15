package ch.boosters.backend.sources.swissski

import ch.boosters.backend.sources.SourceConfig
import ch.boosters.backend.sources.swissski.model.SwissSkiEvent
import ch.boosters.data.Tables.*
import org.jooq.CommonTableExpression
import org.jooq.DSLContext
import org.jooq.Record3
import org.jooq.impl.DSL
import org.springframework.stereotype.Repository
import java.util.*

@Repository
class SwissSkiRepository(
    private val dsl: DSLContext,
    private val sourceConfig: SourceConfig,
    ){

    val sourceId :Int by lazy {
        initSourceId()
    }

    fun getSubcategoryOfCategory(category: String): List<String> {
        val allCategories = getSubcategories(category)
        return allCategories.map { x -> x.value2() }
    }

    fun getSubcategories(category: String): List<Record3<UUID, String, UUID>> {

        val descendants: CommonTableExpression<Record3<UUID, String, UUID>> = DSL.name("descendants")
            .fields("id", "name", "parent_id")
            .`as`(
                DSL.select(SPORTS_TABLE.ID, SPORTS_TABLE.NAME, SPORTS_TABLE.PARENT_ID)
                    .from(SPORTS_TABLE)
                    .where(SPORTS_TABLE.NAME.eq(category))
                    .unionAll(
                        DSL.select(SPORTS_TABLE.ID, SPORTS_TABLE.NAME, SPORTS_TABLE.PARENT_ID)
                            .from(SPORTS_TABLE)
                            .join(DSL.table("descendants"))
                            .on(SPORTS_TABLE.PARENT_ID.eq(DSL.field("descendants.id", UUID::class.java)))
                    )
            )

        return dsl.withRecursive(descendants)
            .select(
                DSL.field("descendants.id", UUID::class.java),
                DSL.field("descendants.name", String::class.java),
                DSL.field("descendants.parent_id", UUID::class.java)
            )
            .from(DSL.table("descendants"))
            .where(
                DSL.notExists(
                    DSL.selectOne()
                        .from(SPORTS_TABLE)
                        .where(SPORTS_TABLE.PARENT_ID.eq(DSL.field("descendants.id", UUID::class.java)))
                )
                    .and(DSL.field("descendants.name", String::class.java).ne(category))
            )
            .fetch()
    }

    fun getParentId(event: SwissSkiEvent): UUID? {
        // not sure if this is a good idea
        val sportsId = "${event.catCode}_${event.disciplineCode}_${event.gender}"

        return dsl.select()
            .from(SPORTS_TABLE)
            .where(SPORTS_TABLE.NAME.eq(sportsId))
            .fetchOne(SPORTS_TABLE.ID)
    }

    fun storeEvents(events: List<SwissSkiEvent>) {
        events.forEach { event ->
            val sportId = getParentId(event)
            // skip events of not subscribed sports
            if (sportId != null) {
                dsl.newRecord(EVENTS_TABLE)
                    .setId(UUID.randomUUID().toString())
                    .setName(event.place)
                    .setSourceId(sourceId)
                    .setStartsOn(event.raceDate)
                    .setSportId(sportId)
                    .store()
            }
        }
    }

    private fun initSourceId(): Int {
        val id = dsl.select()
            .from(SOURCES_TABLE)
            .where(SOURCES_TABLE.NAME.eq(sourceConfig.swissSki.name))
            .fetchOne(SOURCES_TABLE.ID)
        return id!!
    }
}
