package ch.boosters.backend.data.organisation

import ch.boosters.backend.data.configuration.JooqEitherDsl
import ch.boosters.backend.errorhandling.SynciEither
import ch.boosters.data.enums.EventAnswer
import ch.boosters.data.tables.pojos.OrganisationEventResponsesTable
import ch.boosters.data.tables.references.ORGANISATION_EVENT_RESPONSES_TABLE
import org.springframework.stereotype.Repository
import java.time.LocalDateTime
import java.util.UUID

private val RESPONSES = ORGANISATION_EVENT_RESPONSES_TABLE

@Repository
class OrganisationEventResponseRepository(private val dsl: JooqEitherDsl) {

    fun answers(sourceId: Int, eventIds: Collection<String>): SynciEither<List<OrganisationEventResponsesTable>> =
        dsl {
            it.selectFrom(RESPONSES)
                .where(RESPONSES.SOURCE_ID.eq(sourceId))
                .and(RESPONSES.EVENT_ID.`in`(eventIds))
                .fetchInto(OrganisationEventResponsesTable::class.java)
        }

    /** A member has one answer per event; a new answer replaces the old one. */
    fun save(eventId: String, sourceId: Int, userId: UUID, answer: EventAnswer): SynciEither<Int> =
        dsl {
            it.insertInto(RESPONSES)
                .set(RESPONSES.EVENT_ID, eventId)
                .set(RESPONSES.SOURCE_ID, sourceId)
                .set(RESPONSES.USER_ID, userId)
                .set(RESPONSES.ANSWER, answer)
                .onConflict(RESPONSES.EVENT_ID, RESPONSES.SOURCE_ID, RESPONSES.USER_ID)
                .doUpdate()
                .set(RESPONSES.ANSWER, answer)
                .set(RESPONSES.UPDATED_AT, LocalDateTime.now())
                .execute()
        }
}
