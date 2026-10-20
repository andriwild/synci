package ch.boosters.backend.sources.nflverse

import ch.boosters.backend.sources.nflverse.model.NflGame
import org.apache.commons.csv.CSVFormat
import org.apache.commons.csv.CSVParser
import org.apache.commons.csv.CSVRecord
import java.time.LocalDate
import java.time.LocalTime

/** Parses the nflverse games.csv. Columns are looked up by header name, so column order does not matter. */
object NflverseCsvParser {

    private val format: CSVFormat = CSVFormat.RFC4180.builder()
        .setHeader()
        .setSkipHeaderRecord(true)
        .setIgnoreEmptyLines(true)
        .setTrim(true)
        .build()

    fun parse(csv: String): List<NflGame> =
        CSVParser.parse(csv, format).use { parser -> parser.records.map(::toGame) }

    /** teams_colors_logos.csv: team abbreviation (upper case, as in games.csv) -> ESPN logo url */
    fun parseLogos(csv: String): Map<String, String> =
        CSVParser.parse(csv, format).use { parser ->
            parser.records
                .filter { it.get("team_logo_espn").isNotBlank() }
                .associate { it.get("team_abbr").uppercase() to it.get("team_logo_espn") }
        }

    private fun toGame(record: CSVRecord): NflGame = NflGame(
        gameId = record.get("game_id"),
        season = record.get("season").toInt(),
        gameType = record.get("game_type"),
        week = record.get("week").toInt(),
        gameday = LocalDate.parse(record.get("gameday")),
        gametime = record.get("gametime").takeIf { it.isNotBlank() }?.let(LocalTime::parse),
        awayTeam = record.get("away_team"),
        homeTeam = record.get("home_team"),
        location = record.get("location"),
        stadium = record.get("stadium").takeIf { it.isNotBlank() },
    )
}
