package ch.boosters.backend.data.organisation

import ch.boosters.backend.data.organisation.model.MemberAnswer
import ch.boosters.data.enums.EventAnswer
import ch.boosters.data.enums.OrgMemberStatus
import ch.boosters.data.enums.OrgRole
import ch.boosters.data.tables.pojos.OrganisationEventResponsesTable
import ch.boosters.data.tables.pojos.OrganisationMembersTable
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Test
import java.util.UUID

class OrganisationEventResponseServiceTest {

    private val organisationId = UUID.randomUUID()

    private fun member(name: String, role: OrgRole = OrgRole.MEMBER) = MemberRecord(
        OrganisationMembersTable(UUID.randomUUID(), organisationId, UUID.randomUUID(), role, OrgMemberStatus.ACTIVE),
        userName = name,
        userEmail = "$name@synci.ch"
    )

    private fun answer(member: MemberRecord, answer: EventAnswer) =
        OrganisationEventResponsesTable("event-1", 1, member.membership.userId, answer)

    private val admin = member("Zora", OrgRole.ADMIN)
    private val anna = member("anna")
    private val ben = member("Ben")
    private val carla = member("Carla")
    private val active = listOf(admin, anna, ben, carla)

    @Test
    fun `counts yes, no and open answers of the active members`() {
        val answers = listOf(answer(anna, EventAnswer.YES), answer(ben, EventAnswer.NO), answer(admin, EventAnswer.YES))

        val summary = OrganisationEventResponseService.summarise("event-1", active, answers, anna.membership)

        assertEquals(2, summary.yes)
        assertEquals(1, summary.no)
        assertEquals(1, summary.open)
        assertEquals(EventAnswer.YES, summary.myAnswer)
    }

    @Test
    fun `answers of former members are not counted`() {
        val former = member("Dora")

        val summary = OrganisationEventResponseService.summarise(
            "event-1", active, listOf(answer(former, EventAnswer.YES)), anna.membership
        )

        assertEquals(0, summary.yes)
        assertEquals(4, summary.open)
    }

    @Test
    fun `only admins see who answered what, yes first and open last`() {
        val answers = listOf(answer(carla, EventAnswer.NO), answer(ben, EventAnswer.YES), answer(anna, EventAnswer.YES))

        assertNull(OrganisationEventResponseService.summarise("event-1", active, answers, anna.membership).members)
        assertEquals(
            listOf(
                MemberAnswer("anna", EventAnswer.YES),
                MemberAnswer("Ben", EventAnswer.YES),
                MemberAnswer("Carla", EventAnswer.NO),
                MemberAnswer("Zora", null)
            ),
            OrganisationEventResponseService.summarise("event-1", active, answers, admin.membership).members
        )
    }
}
