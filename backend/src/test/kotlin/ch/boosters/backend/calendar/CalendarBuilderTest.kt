package ch.boosters.backend.calendar

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import java.time.LocalDateTime

class CalendarBuilderTest {

    private val start = LocalDateTime.of(2026, 10, 13, 19, 0)

    @Test
    fun `location and description are written when present`() {
        val ics = CalendarBuilder.build(
            listOf(CalendarEvent("org-1", "Training", start, start.plusHours(2), "Sporthalle", "Bitte Hallenschuhe")), "Test"
        ).toString()

        assertTrue(ics.contains("SUMMARY:Training"))
        assertTrue(ics.contains(Regex("(?m)^LOCATION:Sporthalle")))
        assertTrue(ics.contains(Regex("(?m)^DESCRIPTION:Bitte Hallenschuhe")))
        assertTrue(ics.contains("UID:org-1@synci.ch"))
        assertTrue(ics.contains("NAME:Synci - Test"))
    }

    @Test
    fun `blank location and description are omitted`() {
        val ics = CalendarBuilder.build(listOf(CalendarEvent("1", "Match", start, start.plusHours(2), " ", "")), "Test").toString()

        // the VTIMEZONE block contains X-LIC-LOCATION, so only look at property lines
        assertFalse(ics.contains(Regex("(?m)^LOCATION:")))
        assertFalse(ics.contains(Regex("(?m)^DESCRIPTION:")))
    }

    @Test
    fun `the calendar carries its name and time zone for Google Calendar`() {
        val ics = CalendarBuilder.build(emptyList(), "Test").toString()

        assertTrue(ics.contains(Regex("(?m)^X-WR-CALNAME:Synci - Test\\r?$")))
        assertTrue(ics.contains(Regex("(?m)^X-WR-TIMEZONE:Europe/Zurich\\r?$")))
    }

    @Test
    fun `event times are Swiss local time`() {
        val ics = CalendarBuilder.build(listOf(CalendarEvent("1", "Match", start, start.plusHours(2))), "Test").toString()

        assertTrue(ics.contains("DTSTART;TZID=Europe/Zurich:20261013T190000"))
        assertTrue(ics.contains("DTEND;TZID=Europe/Zurich:20261013T210000"))
    }

    @Test
    fun `an event without end becomes an all-day event`() {
        val ics = CalendarBuilder.build(listOf(CalendarEvent("1", "GV", start, null)), "Test").toString()

        assertTrue(ics.contains("DTSTART;VALUE=DATE:20261013"))
    }

    @Test
    fun `events with the same id are only written once`() {
        val event = CalendarEvent("1", "Match", start, start.plusHours(2))
        val ics = CalendarBuilder.build(listOf(event, event.copy(name = "Match again")), "Test").toString()

        assertEquals(1, Regex("BEGIN:VEVENT").findAll(ics).count())
    }
}
