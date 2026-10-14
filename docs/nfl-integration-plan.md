# NFL-Integration über nflverse – Implementierungsplan

## Context

Synci soll NFL-Spielpläne als abonnierbare Kalender anbieten. SwissTXT liefert keine NFL-Daten. Zuerst war API-Sports («API-American-Football») vorgesehen; der Test mit dem Key des Nutzers hat aber gezeigt, dass der Free-Plan die laufende Saison nicht liefert (`"Free plans do not have access to this season, try from 2022 to 2024"`). Der Nutzer hat sich deshalb für **nflverse** entschieden: das `schedules`-Release von `nflverse/nflverse-data`, eine CSV ohne Key, CC-BY-4.0, mit allen 272 Spielen der Saison 2026 (Playoffs folgen automatisch), Kickoff in Eastern Time, Heim/Gast-Kürzeln und Stadion. Live geprüft am 13.10.2026: `games.csv` (2,2 MB, HTTP 200) und `games.csv.gz` (0,5 MB) sind abrufbar; Zeitangabe gegen ESPN verifiziert (`2026_07_NE_CHI` 22.10. 20:15 ET = `2026-10-23T00:15Z`).

Die Integration folgt dem bestehenden Quellen-Muster (`backend/src/main/kotlin/ch/boosters/backend/sources/swisstxt/`): YAML-Konfig unter `sources/`, `@ConfigurationProperties`, Service mit `lastSync`-Gate, WebClient, Repository-Upserts über jOOQ, Aufruf aus `EventSyncJob`, Sport-Nodes per Flyway-Migration. Arbeitsbasis: Branch `main` (sauber, `aff7898`), Migrationen bis `V3_36`.

**nflverse-CSV, verifiziert:** Spalten u. a. `game_id, season, game_type, week, gameday, weekday, gametime, away_team, away_score, home_team, home_score, location, result, total, overtime, old_game_id, gsis, nfl_detail_id, pfr, pff, espn, ftn, …, roof, surface, temp, wind, …, stadium_id, stadium`. `game_type` 2026 bisher nur `REG` (272 Zeilen); historisch `REG, WC, DIV, CON, SB`. `gametime` ist `HH:mm` Eastern Time oder leer (TBD). `location` ist `Home` oder `Neutral`. Quoted Felder kommen vor (`""`), daher RFC-4180-Parser nötig. Scores sind leer bis zum Spielende.

**Zur Dokumentation – API-Sports mit dem Test-Key verifiziert (13.10.2026, 3 Requests, Antworten im Scratchpad `apisports/`), wird in diesem Plan nicht gebaut:**
- Host `https://v1.american-football.api-sports.io`, Header `x-apisports-key`, Rate-Limit-Header `x-ratelimit-requests-limit: 100` / `-remaining` (Tag) und `x-ratelimit-limit: 10` / `-remaining` (Minute).
- Envelope `{get, parameters, errors, results, response[]}`; `paging` ist **nicht** bei allen Endpoints vorhanden (fehlt bei `/leagues` und `/games`) → optional parsen. `errors` ist bei Erfolg `[]` (leere Liste), bei Fehler ein Objekt (`{"plan": "…"}`) → als `JsonElement` einlesen.
- `GET /leagues?id=1`: `league{id:1, name:"NFL", logo}`, `country`, `seasons[{year, start, end, current, coverage}]`; Saison **2026 ist `current: true`** (`2026-08-07` bis `2027-02-14`).
- `GET /teams?league=1&season=2024`: 34 Einträge `{id, name, code, city, coach, owner, stadium, established, logo, country}` (32 Teams + die beiden Pro-Bowl-Teams AFC/NFC).
- `GET /games?league=1&season=2024&timezone=Europe/Zurich`: 335 Spiele, `item{game, league, teams, scores}`; `game{id:Int, stage, week, date{timezone:"Europe/Zurich", date, time, timestamp}, venue{name, city}, status{short, long, timer}}`; `league.season` ist ein **String** (`"2024"`); `teams.home/away{id, name, logo}`; `scores.home/away{quarter_1..4, overtime, total}`.
  - `stage`: `Regular Season` (272), `Pre Season` (49), `Post Season` (14).
  - `week`: `Week 1`…`Week 18`, `Hall of Fame Weekend` (Pre), `Wild Card`, `Divisional Round`, `Conference Championships`, `Pro Bowl`, `Super Bowl` (Post).
  - `status.short`: `NS` (Not Started), `FT` (Finished), `null` mit `status.long = "Final/OT"` → `short` ist nullable. Abgesagt/verschoben kamen in 2024 nicht vor; defensiv `CANC`/`PST` behandeln.
  - Der `timezone`-Parameter wird respektiert (`date`/`time` bereits in Zürich-Zeit); `timestamp` (Unix) bleibt die robuste Quelle für die Umrechnung.
- **Blocker Free-Plan:** `/games` und `/teams` für `season=2026` antworten mit `errors.plan: "Free plans do not have access to this season, try from 2022 to 2024."` → Grund für die Entscheidung zugunsten nflverse. Die Fixtures bleiben im Scratchpad, falls API-Sports später mit bezahltem Plan nachgerüstet wird.

## Entscheidungen

- **Neuer Branch `feature/nfl` ab `main`** (erster Schritt der Umsetzung).
- **Baum:** `AMERICAN_FOOTBALL` («American Football») → `NFL` («NFL») → `NFL_REGULAR_SEASON` («Regular Season») und `NFL_PLAYOFFS` («Playoffs»). Analog zu `NATIONAL_LEAGUE_QUALIFICATION/PLAYOFF`. Wer `NFL` abonniert, bekommt beide Phasen (CalendarService flacht Sub-Sports ab). Teams werden wie bei Hockey an der Phasen-Node verlinkt, an der ihre Spiele hängen.
- **Zuordnung `game_type`:** `REG` → `NFL_REGULAR_SEASON`; `WC`, `DIV`, `CON`, `SB` → `NFL_PLAYOFFS`. Preseason ist in nflverse nicht enthalten. Zuordnung in der YAML konfigurierbar; unbekannte Typen werden geloggt und übersprungen.
- **Saison:** aktuelle Saison = grösste `season` in der CSV, optional per Konfig überschreibbar. Nur Zeilen dieser Saison werden verarbeitet, nur zukünftige Spiele gespeichert (gleiches `filterPastEvents`-Verhalten wie SwissTXT).
- **Zeiten:** `gameday` + `gametime` in `America/New_York` → `Europe/Zurich` → `LocalDateTime` (CalendarService hängt statisch Europe/Zurich an). Verifiziert: `2026_07_NE_CHI` 22.10. 20:15 ET = ESPN `2026-10-23T00:15Z` = 23.10. 02:15 Zürich. `ends_on` = Start + 3 h 15 min. Zeilen ohne `gametime` (TBD) werden übersprungen; sobald die Zeit nachgetragen ist, legt der nächste Sync das Spiel an. Verschiebungen aktualisieren über den Upsert `starts_on/ends_on`.
- **IDs:** `events_table.id` = nflverse `game_id` (z. B. `2026_07_NE_CHI`), `teams_table.id` = nflverse-Kürzel (`NE`, `KC`, …), `source_id` = neue Quelle `NFLVERSE`, `gender = MAN`.
- **Event-Name:** Synci-Konvention «Heim - Gast» mit vollen Teamnamen («Chicago Bears - New England Patriots»); bei `location = Neutral` zusätzlich « (Stade de France)». Max. 100 Zeichen (Spalte `name varchar(100)`), bei Überlänge Kürzel verwenden.
- **Teamnamen:** die 32 Kürzel → Namen stehen fest in der YAML-Konfig (kein zweiter Download; z. B. `LA` = Los Angeles Rams, `LAC`, `LV`, `WAS`, `JAX`, `SF`, `TB`, `KC`, `GB`, `NE`, `NO`, `NYG`, `NYJ`, …). Unbekanntes Kürzel → Warnung, Kürzel als Name.
- **CSV-Parsing:** neue Abhängigkeit `org.apache.commons:commons-csv:1.10.0` (RFC-4180). Download als Plain-CSV; Fallback auf `games.csv.gz` (`GZIPInputStream`) und danach auf den Spiegel `https://raw.githubusercontent.com/nflverse/nfldata/master/data/games.csv`. Gleiches Spaltenschema.
- **Wiederverwendung statt Duplikat:** die generischen Upsert-/Sync-Time-Queries aus `SwissTxtRepository` werden in ein neues `sources/common/SourceSyncRepository.kt` gezogen, das die Quellen-ID als Parameter nimmt. `SwissTxtRepository` bleibt unverändert (kein Risiko für die laufende Quelle); nur `filterPastEvents` wandert nach `sources/common/EventFilters.kt` und wird von beiden Services genutzt.
- **Attribution:** CC-BY-4.0 → Hinweis «Daten: nflverse» im Event-Namen? Nein (100-Zeichen-Grenze); stattdessen im Quellen-Eintrag/README und später in der Event-Beschreibung, falls das Kalendermodell eine Beschreibung bekommt.
- **Frontend:** keine Änderung nötig, der Tree ist generisch; neue Nodes erscheinen über `label`.

## Dateien

**Datenbank**
- `backend/src/main/resources/db/migration/V3_37__add_nfl.sql`
  - `INSERT INTO SOURCES_TABLE (name) VALUES ('NFLVERSE');`
  - `AMERICAN_FOOTBALL` (label «American Football») → `NFL` («NFL») → `NFL_REGULAR_SEASON` («Regular Season»), `NFL_PLAYOFFS` («Playoffs»); Muster `V3_27__add_and_update_hockey.sql` (DO-Block mit `SELECT id INTO`).

**Konfiguration**
- `backend/src/main/resources/sources/nflverse.yml`:
  ```yaml
  nflverse:
    name: NFLVERSE
    url: https://github.com/nflverse/nflverse-data/releases/download/schedules/games.csv
    fallback-urls:
      - https://github.com/nflverse/nflverse-data/releases/download/schedules/games.csv.gz
      - https://raw.githubusercontent.com/nflverse/nfldata/master/data/games.csv
    season:                      # leer = grösste Saison in der Datei
    source-timezone: America/New_York
    target-timezone: Europe/Zurich
    game-duration-minutes: 195
    game-types:
      REG: NFL_REGULAR_SEASON
      WC: NFL_PLAYOFFS
      DIV: NFL_PLAYOFFS
      CON: NFL_PLAYOFFS
      SB: NFL_PLAYOFFS
    teams:
      ARI: Arizona Cardinals
      ATL: Atlanta Falcons
      # … alle 32 Kürzel (BAL, BUF, CAR, CHI, CIN, CLE, DAL, DEN, DET, GB, HOU, IND, JAX, KC, LA, LAC, LV, MIA, MIN, NE, NO, NYG, NYJ, PHI, PIT, SEA, SF, TB, TEN, WAS)
  ```
- `backend/src/main/resources/application.yml`: `spring.config.import` um `classpath:sources/nflverse.yml` ergänzen.
- `backend/build.gradle.kts`: `implementation("org.apache.commons:commons-csv:1.10.0")`.

**Backend-Code** (`backend/src/main/kotlin/ch/boosters/backend/`)
- `sources/common/SourceSyncRepository.kt` (neu): `sourceIdByName(name)`, `upsertTeams(sourceId, teams)`, `upsertTeamEvents(sourceId, sportId, events)` (Event-Upsert + `events_teams_table` wie `SwissTxtRepository.createEventQueries/linkTeamsToEvents`), `lastSyncTime(sourceId)`, `storeSyncTime(sourceId)`; nutzt `JooqEitherDsl` und die Helfer in `SharedQueries.kt`.
- `sources/common/EventFilters.kt` (neu): `fun <T : BaseEvent> List<T>.futureOnly(now: LocalDateTime = LocalDateTime.now()): List<T>`; `SwissTxtService.filterPastEvents` darauf umstellen.
- `sources/nflverse/NflverseConfig.kt` (neu): `@ConfigurationProperties(prefix = "nflverse")` wie `SwissTxtConfig` (Felder wie in der YAML, `teams: MutableMap<String, String>`, `gameTypes: MutableMap<String, String>`).
- `sources/nflverse/model/NflGame.kt` (neu): `data class NflGame(gameId, season: Int, gameType, week: Int, gameday: LocalDate, gametime: LocalTime?, awayTeam, homeTeam, location, stadium)`.
- `sources/nflverse/NflverseCsvParser.kt` (neu): `parse(csv: String): List<NflGame>` mit commons-csv, Header-basiert (`game_id, season, game_type, week, gameday, gametime, away_team, home_team, location, stadium`); leere `gametime` → `null`.
- `sources/nflverse/NflGameMapper.kt` (neu, reine Funktionen): `sportKeyFor(gameType, config): String?`, `toTeamEvent(game, config): TeamEvent?` (TZ-Umrechnung, Name, Dauer, Neutral-Zusatz, 100-Zeichen-Grenze), `teamsOf(events, config, sourceId): List<Team>`, `currentSeason(games, config): Int`.
- `sources/nflverse/NflverseService.kt` (neu): `update(): SynciEither<Unit>` – `lastSync`-Gate wie `SwissTxtService.update()`, Download via `WebClient` (Buffer 16 MB; Fallback-Kette inkl. gz-Dekompression), parse, Saison bestimmen, Spiele nach Sport-Key gruppieren, pro Key: `sportsRepository.sportIdByName`, `upsertTeams`, `teamSportsRepository.upsertTeams(teams, sportId)`, `upsertTeamEvents` (nur `futureOnly`); am Ende `storeSyncTime`. Fehler als `SynciError` (`ElementNotFound` für fehlende Sport-Nodes); wenn alle Download-URLs scheitern, `lastSync` nicht setzen.
- `job/EventSyncJob.kt`: `nflverseService.update()` in die `updates`-Liste aufnehmen (Liste wird bereits einzeln ausgewertet, ein Fehler blockiert die andere Quelle nicht).

**Tests** (`backend/src/test/`)
- `resources/nflverse/games_sample.csv`: ~8 Zeilen aus der echten Datei (Header + 2025-SB-Zeile, 2026-REG-Zeilen inkl. `2026_07_NE_CHI`, eine mit `""`-Feldern, eine ohne `gametime`, eine `Neutral`).
- `kotlin/.../sources/nflverse/NflverseCsvParserTest.kt`: Anzahl Zeilen, quoted Felder, fehlende Zeit → `null`, Spaltenreihenfolge egal (Header-basiert).
- `kotlin/.../sources/nflverse/NflGameMapperTest.kt`: `2026-10-22 20:15` ET → `2026-10-23T02:15` Zürich; DST-Kante `2026-11-01 13:00` ET (EST) → `19:00` Zürich (CET); `ends_on` = +195 min; `SB` → Playoffs, unbekannter Typ → `null`; Name-Konvention, Neutral-Zusatz, 100-Zeichen-Grenze; unbekanntes Kürzel → Kürzel als Name; `currentSeason` = max(season) bzw. Override.

## Umsetzungsreihenfolge

1. `git switch -c feature/nfl` auf `main`.
2. Migration + YAML + `application.yml` + Gradle-Dependency.
3. `SourceSyncRepository`, `EventFilters` (+ SwissTxt auf `futureOnly` umstellen).
4. Config, Modell, Parser, Mapper + Unit-Tests (grün bevor der Service gebaut wird).
5. Service + Job-Anbindung.
6. Lokaler Lauf und Verifikation, dann Commits (Schritte 2–5 in 2–3 Commits).

## Verifikation

1. `cd backend && ./gradlew test` (Parser-/Mapper-Tests, bestehender `SportDomainTest`).
2. Lokale DB gemäss Memory: Postgres auf Port 5434, `set -a; source .env; set +a`, dann `DB_PORT=5434 ./gradlew bootRun --args='--spring.profiles.active=local --ch.boosters.db.jdbcUrl=jdbc:postgresql://localhost:5434/synci-db'`. Flyway muss `V3_37` anwenden.
3. Der Quartz-Job startet 3 s nach Boot: Log zeigt «Fetching …games.csv» und «Successfully inserted data»; `SELECT count(*) FROM events_table e JOIN sources_table s ON s.id=e.source_id WHERE s.name='NFLVERSE'` = Anzahl zukünftiger 2026-Spiele (Stand 13.10.: Woche 7 bis 18, rund 180); 32 Teams in `teams_table` mit `source_id` NFLVERSE; `teams_sports_table` verlinkt sie mit `NFL_REGULAR_SEASON`.
4. `GET /api/sports` enthält `AMERICAN_FOOTBALL → NFL → Regular Season/Playoffs`; im Frontend erscheint der Baum ohne Änderung, Team-Preview zeigt 32 Teams.
5. Sync-Config mit `NFL` anlegen, `GET /api/calendars/{id}/subscribe` (siehe `src/test/http/calendar.http`): ICS enthält «Chicago Bears - New England Patriots» mit `DTSTART;TZID=Europe/Zurich:20261023T021500` (Gegenprobe ESPN: `2026-10-23T00:15Z`).
6. Zweiter Job-Lauf innerhalb 12 h wird durch das `lastSync`-Gate übersprungen; Wiederholung erzeugt keine Duplikate (Upsert auf `(id, source_id)`, `events_teams_table` mit `onDuplicateKeyIgnore`).


