package ch.boosters.backend.data.team

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Test

class TeamLogosTest {

    @Test
    fun `SwissTXT logos are addressed by the team id`() {
        assertEquals("https://cdn-csd.swisstxt.ch/images/sport/club/logo/medium/3089.png", TeamLogos.swissTxtLogo("3089"))
    }

    @Test
    fun `SwissTXT logos get the large and 300 variants for dense screens`() {
        assertEquals(
            "https://cdn-csd.swisstxt.ch/images/sport/club/logo/medium/3089.png 1x, " +
                "https://cdn-csd.swisstxt.ch/images/sport/club/logo/large/3089.png 2x, " +
                "https://cdn-csd.swisstxt.ch/images/sport/club/logo/300/3089.png 3x",
            TeamLogos.srcSet(TeamLogos.swissTxtLogo("3089")),
        )
    }

    @Test
    fun `other logos have no srcset`() {
        assertNull(TeamLogos.srcSet("https://a.espncdn.com/i/teamlogos/nfl/500/chi.png"))
        assertNull(TeamLogos.srcSet(null))
    }
}
