package ch.boosters.backend.data.team

/**
 * Team logos. SwissTXT logos live on its CDN under the team id in three sizes
 * (medium ~100px, large ~150px, 300 ~300px); teams without a logo answer with 404.
 */
object TeamLogos {
    private const val SWISSTXT_CDN = "https://cdn-csd.swisstxt.ch/images/sport/club/logo"
    private val SWISSTXT_MEDIUM = Regex("""^${Regex.escape(SWISSTXT_CDN)}/medium/([^/]+)\.png$""")

    fun swissTxtLogo(teamId: String) = "$SWISSTXT_CDN/medium/$teamId.png"

    /** srcset with the sharper variants for high-density screens; null for logos available in one size only */
    fun srcSet(logoUrl: String?): String? {
        val id = logoUrl?.let { SWISSTXT_MEDIUM.find(it) }?.groupValues?.get(1) ?: return null
        return "$SWISSTXT_CDN/medium/$id.png 1x, $SWISSTXT_CDN/large/$id.png 2x, $SWISSTXT_CDN/300/$id.png 3x"
    }
}
