package ch.boosters.backend.data.event

import ch.boosters.data.enums.GenderType
import ch.boosters.data.tables.pojos.EventsTable
import ch.boosters.data.tables.pojos.TeamsTable
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import java.time.LocalDateTime
import java.util.UUID

class EventResponseTest {

    private fun event(name: String) = EventsTable(id = "1", sourceId = 3, name = name, startsOn = LocalDateTime.of(2026, 10, 25, 21, 0), sportId = UUID.randomUUID())
    private fun team(id: String, name: String) = TeamsTable(id = id, sourceId = 3, name = name, gender = GenderType.MAN)

    @Test
    fun `orders the teams like the event name`() {
        val response = EventResponse.of(event("FC Barcelona - Real Madrid"), listOf(team("5477", "Real Madrid"), team("5469", "FC Barcelona")))

        assertEquals(listOf("FC Barcelona", "Real Madrid"), response.teams.map { it.name })
    }

    @Test
    fun `puts teams that the name does not mention last and drops repeats`() {
        val response = EventResponse.of(
            event("NE - CHI"),
            listOf(team("chi", "Chicago Bears"), team("ne", "New England Patriots"), team("chi", "Chicago Bears")),
        )

        assertEquals(listOf("chi", "ne"), response.teams.map { it.id })
    }

    @Test
    fun `has no teams for an event without teams`() {
        assertEquals(emptyList<Any>(), EventResponse.of(event("Weltcup Abfahrt"), emptyList()).teams)
    }
}
