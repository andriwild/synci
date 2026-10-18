# Recherche: Öffentliche Event-APIs als neue Datenquellen für Synci

Stand: 13. Oktober 2026. Ziel: Quellen, aus denen Synci zusätzliche abonnierbare Kalender (iCal) bauen könnte: Konzerte, Anlässe, Openairs, E-Sport, weitere Sportarten, Feiertage und andere kalenderrelevante Dinge. Bewertet nach Zugang, Kosten/Limits, Abdeckung (Schweiz!), Lizenz (Synci veröffentlicht die Daten weiter als iCal-Feeds, deshalb zählen Nicht-kommerziell-Klauseln und Attribution) und Aufwand.

Wichtig: Zahlen zu Limits stammen teils aus Drittquellen und müssen vor einer Integration mit einem eigenen Key verifiziert werden. Markiert mit (v) = offiziell belegt, (d) = Drittquelle.

## Kurzfazit: die besten Kandidaten

| Prio | Quelle | Was | Zugang | Warum |
|---|---|---|---|---|
| 1 | **Eventfrog Public API** | Schweizer Konzerte, Openairs, Partys, Vereinsanlässe (120k+ Events (d)) | Public-API-Key, lesend, JSON | Die einzige breite Schweizer Eventquelle mit dokumentierter API und Rubriken/Region/Datum-Filtern |
| 2 | **Ticketmaster Discovery API** | Internationale Konzerte/Shows/Sport, CH ist im Länder-Set | Free Key, 5'000 Calls/Tag (v) | Grosse Abdeckung, stabil, gute Doku; CH-Tiefe muss getestet werden (Hallenstadion etc. läuft oft über Ticketcorner) |
| 3 | **PandaScore** | E-Sport-Spielpläne (LoL, CS2, Valorant, Dota 2, R6, RL …) | Free Plan, 1'000 Req/h (v), Fixtures gratis (v) | Einzige seriöse kostenlose E-Sport-Fixture-API, passt exakt ins Synci-Modell «Liga/Team abonnieren» |
| 4 | **OpenHolidays API** | Feiertage + Schulferien aller 26 Kantone | Kein Key, JSON + iCal, CC BY 4.0 | Trivial zu integrieren, hoher Alltagsnutzen («Schulferien ZH» als Abo) |
| 5 | **Launch Library 2 (The Space Devs)** | Raketenstarts, Raumfahrt-Events | Kein Key, 15 Req/h anonym (v) | Nischen-Highlight, täglicher Sync reicht |
| 6 | **TVmaze / TMDB / IGDB** | Serien-Episoden, Kinostarts, Game-Releases | Gratis (TVmaze ohne Key) | «Release-Kalender» als neue Kategorie |
| 7 | **football-data.org / OpenLigaDB / Jolpica F1** | Fussball-Ligen, Bundesliga, Formel 1 | Gratis | Ergänzung zu bestehenden Sportquellen |

## 1. Konzerte, Tickets, Anlässe

| Quelle | Zugang & Limits | Abdeckung | Lizenz / Haken | Eignung |
|---|---|---|---|---|
| **Eventfrog Public API** (api.eventfrog.net, Doku docs.api.eventfrog.net/#publicapi-v1) | Public-API-Key (über Eventfrog-Konto/Beratung), lesend: Events, Eventgruppen, Rubriken, Locations; Filter Region/Rubrik/Datum; JSON | Schweiz, breit (Konzerte, Openairs, Clubs, Vereine, Märkte) | Nutzungsbedingungen/Limits nicht öffentlich dokumentiert → vor Integration mit Eventfrog klären; Bildrechte liegen beim Nutzer (openeventdata.ch) | **Sehr hoch** |
| **Ticketmaster Discovery API v2** | Free Key, 5'000 Calls/Tag (v), 2–5 Req/s (widersprüchlich); höhere Limits nach Review | 230k+ Events weltweit; CH im Discovery-Feed-Länder-Set (v); Int. Discovery API nimmt keine neuen Keys mehr | Branding/Attribution-Pflicht; Preisdaten spärlich; CH-Abdeckung unklar, da Ticketcorner (Eventim) dominiert | **Hoch** (testen mit `countryCode=CH`) |
| **Switzerland Tourism OpenData API** (developer.myswitzerland.io) | Free Key per Registrierung, Rate-Limits, kein Push (polling) | Destinationen, Aktivitäten, «Events» in 16 Sprachen | Meist CC BY-SA 4.0 (d); Key nicht weitergeben; Event-Volumen unklar | Mittel (Volumen prüfen) |
| **discover.swiss (Infocenter OpenData)** | Developer-Account, OpenAPI, schema.org/JSON-LD | Tourismus-Knowledge-Graph inkl. Events | Drittquelle meldet nur ~21 Event-Objekte → praktisch leer | Niedrig |
| **JamBase Data API** | Developer-Plan 0 $/Monat, 1'000 Calls/Monat, nur 6 Monate voraus, nicht-kommerziell (v) | Konzerte weltweit (5M+ Performances, d) | Nicht-kommerziell; Attribution | Niedrig (Limit zu klein) |
| **Bandsintown API** | `app_id` auf Anfrage, Artist-Endpoint `rest.bandsintown.com/artists/{name}/events` | Konzerte pro Künstler weltweit | Lizenz nur «Display on Your Websites», kein Discover-Endpoint, Weiterverbreitung als iCal fraglich | Niedrig/Mittel (nur «Künstler abonnieren») |
| **SeatGeek Platform API** | Free `client_id` | USA/Kanada, international «to a lesser degree» | Für CH nutzlos | Niedrig |
| **Ticketino REST API** | Kostenlos, aber Veranstalter-Kontext | Eigene Events | Kein Discover | Niedrig |
| **SRG SSR MX3 API** | Registrierung, nicht-kommerziell (d) | Schweizer Bands, Konzerte (mx3.ch) | Nicht-kommerziell; Konzertabdeckung klein | Niedrig |

**Tot oder unbrauchbar:** Eventbrite (Public-Search seit 2020 weg, nur eigene Orgs), Songkick (keine neuen Keys, nur Partner mit Lizenzgebühr), AllEvents.in (ab 500 USD/Monat, keine Hobby-Keys), PredictHQ (Enterprise, ab ~500 USD/Jahr (d)), Meetup (nur mit Pro-Abo 55 USD/Gruppe/Monat), OpenAgenda (Frankreich-zentriert), Luma (nur eigene Kalender, Discover inoffiziell), Ticketcorner/Starticket/Eventim/Petzi (keine öffentliche API gefunden), Resident Advisor/Dice/Skiddle (nichts belastbares gefunden).

**Openairs/Festivals Schweiz:** keine Open-Data-Quelle. Festivalticker, festivalsunited, festival-alarm, linker.ch sind nur Websites (festival-alarm hat strukturierte Tabellen, aber keine API). Beste Lösung: Eventfrog-Rubrik «Festival/Openair» + Ticketmaster.

## 2. Schweiz-spezifische Open Data

- **openeventdata.ch**: Schweizer Verein für offene Event-Schnittstellen («18'000 Veranstaltungen, 40 Schnittstellen»), Partner fugu.ch, qle.ch, bewegungsmelder.ch; listet Eventfrog als «publicly documented API». Die Schnittstellen-Seite war per Fetch nicht erreichbar (404) → manuell anschauen, dort steht der Katalog der 40 Anbieter.
- **opendata.swiss**: CKAN-API (`/api/3/action/package_search`), aber keine laufenden Event-Agenden gefunden; Abfrage war für mich blockiert (403). Stadtportale Zürich (data.stadt-zuerich.ch, ~925 Datasets), Basel (data.bs.ch), Luzern (opendata-luzern.org) haben keine Event-Agenda-Datasets in den Treffern; Zürich Tourismus API v2 (schema.org) deckt Locations, Events unklar.
- **Feiertagskalender.ch (fcal.ch) API**: Feiertage + Schulferien bis Gemeinde-Ebene (JSON/XML/CSV, ab 2003); privat gratis, geschäftlich mehrere Regionen/Jahre kostenpflichtig → OpenHolidays ist die bessere Wahl.
- **Swiss Unihockey API** – im Detail geprüft (13.10.2026, Live-Tests ohne Key):
  - Host `https://api-v2.swissunihockey.ch/api` («Business Server API», Table API). `/api` meldet `authentication: none`. Öffentliche Endpoints laut `/api/doc/table/overview`: `calendars, clubs, cups, games, game_events, groups, leagues, national_players, players, rankings, teams, topscorers, seasons` (private: `sessions`, `ui/players`). Partner-Credentials (`it@swissunihockey.ch`) nur für private Endpoints.
  - Antwortformat ist UI-orientiert («table», «dropdown», «attribute_list» mit `headers`/`regions`/`rows`/`cells`), nicht entity-orientiert → Parser muss Zellen nach Header-Keys lesen. Lokalisierung nur de-CH.
  - **`/api/calendars` liefert fertige iCal-Feeds** (`text/calendar`, RFC 5545, TZ Europe/Zurich, `UID game-<id>`, SUMMARY «Heim - Gast (Resultat)», LOCATION, GEO, URL zum Game-Detail): `?team_id=` (1 Monat zurück, 12 Monate voraus; Test Zug United: 24 Events), `?club_id=` (Test: 121 Events), `?season=&league=&game_class=&group=` (ganze Saison; Test L-UPL Herren 2025/26: 132 Events). Cache-Control max-age=240.
  - Navigation: `/api/seasons` (2026 = 26/27), `/api/leagues?season=` (Dropdown mit `league`+`game_class`; L-UPL = league 24, NLB = 2, 1. Liga = 3 … bis 4. Liga; game_class 11/12 Herren, 21/22 Damen), `/api/groups?season=&league=&game_class=` («Gruppe 1»…), `/api/clubs` (alle Vereine mit club_id), `/api/teams?league=&game_class=&season=` (Table ohne IDs; Team-IDs kommen aus `team_detail`-Links in `/api/games` oder `mode=by_club&club_id=`), `/api/games?mode=list|team|club|current` (Spielliste mit Datum/Zeit, Ort inkl. Koordinaten, Teams mit Logos, Resultat; `mode=list` braucht `group`, Ausnahme L-UPL), `/api/games/:id` (Detail: Datum, Zeit, Ort, Schiedsrichter, Zuschauer), `/api/rankings`.
  - Kein Rate-Limit beobachtet (10 schnelle Calls → 200, keine RateLimit-Header). Keine Nutzungsbedingungen/Lizenz dokumentiert; das Community-WordPress-Plugin spricht von «kostenloser Swiss-Unihockey-API» und verlinkt die ToS von swissunihockey.ch → vor Produktivnutzung kurze Anfrage an it@swissunihockey.ch empfohlen.
  - Zweiter Host `https://wc.swissunihockey.ch` (gleiches Table-Format, Doku-Link auf `office.swissunihockey.ch/api/legacy/doc`): `/games`, `/teams` offen, aber `/calendars`, `/api/*` → 403 «Endpoint nicht erlaubt». `office.swissunihockey.ch/api/legacy/*` verlangt Partner-`auth_token`. Die v3-API (JSON:API, `/api/v3/games?filter[from_date]…`) ist dokumentiert, antwortet aber 404 → nicht nutzbar. **Fazit: api-v2 ist der nutzbare Host; da es «legacy» ist, Abschaltrisiko einplanen.**
  - Eignung für Synci: **sehr hoch**. Mapping: Unihockey → Liga (league+game_class, ggf. Gruppe) → Team; Events aus `/api/games` oder direkt aus den ICS-Feeds (einfachster Weg: ICS parsen, `UID game-<id>` als sourceId). Spielansetzungen ändern sich (Verschiebungen) → täglicher Sync wie bei SwissTXT.

### Vorschlag: Liga-Struktur von Swiss Unihockey im Synci-Baum

**Ist-Zustand:** `UNIHOCKEY` existiert (SwissTXT, `swisstxt.yml` Zeile 268 ff.): `UNIHOCKEY_NLA` (+ `_QUALIFICATION`/`_PLAYOFF`), `UNIHOCKEY_NLA_WOMEN` (+ Phasen), `UNIHOCKEY_WM`, `UNIHOCKEY_WM_WOMEN`. Baum-Konventionen: `sports_table(id, name, parent_id, label)`, `name` = technischer Schlüssel (Lookup `SportsRepository.sportIdByName`), Quelle = YAML unter `src/main/resources/sources/*.yml` + `@ConfigurationProperties`, Events `(id, source_id)`, Teams `(id, source_id)` + `teams_sports_table(team_id, sport_id)`.

**API-Dimensionen → Baumebenen**

| Swiss-Unihockey-Dimension | Synci-Ebene | Beispiel `name` / `label` |
|---|---|---|
| Sportart | Ebene 1 (existiert) | `UNIHOCKEY` / Unihockey |
| `league` + `game_class` (11 Herren GF, 12 Herren KF, 21 Damen GF, 22 Damen KF) | Ebene 2 | `UNIHOCKEY_LUPL_MEN` / «L-UPL Herren», `UNIHOCKEY_NLB_WOMEN` / «NLB Damen», `UNIHOCKEY_1LIGA_MEN_KF` / «1. Liga Herren Kleinfeld» |
| `group` («Gruppe 1»…) bei Ligen mit mehreren Gruppen | Ebene 3 (nur wo nötig) | `UNIHOCKEY_1LIGA_MEN_G1` / «Gruppe 1» |
| Team (Name aus ICS-SUMMARY bzw. `team_detail`-ID aus `/api/games`) | Team an der Liga-/Gruppen-Node | `teams_table(id='429603' oder Slug, source_id=4)` |
| Spiel (`UID game-<id>`) | Event an derselben Node, `events_teams_table` für Heim/Gast | `events_table(id='1097067', source_id=4)` |
| Saison (`/api/seasons`, 2026 = 26/27) | keine Ebene; Sync nimmt immer die aktuelle Saison | – |
| Phase (Quali/Playoff) | **keine** Ebene (Swiss-Unihockey-Feeds sind nicht nach Phase getrennt; «Runde N» steht nur in DESCRIPTION) | abweichend von SwissTXT-Unihockey |
| Cup (`/api/cups`) | optional Ebene 2 `UNIHOCKEY_CUP_MEN` | später |

```
UNIHOCKEY
├── L-UPL Herren            (league 24, gc 11)   ← Teams + Events direkt hier
├── L-UPL Damen             (league 24, gc 21)
├── NLB Herren              (league 2,  gc 11)
├── NLB Damen               (league 2,  gc 21)
├── 1. Liga Herren GF       (league 3,  gc 11)
│   ├── Gruppe 1            ← Teams + Events
│   └── Gruppe 2
├── 1. Liga Herren KF       (league 3,  gc 12)
│   └── …
├── 2./3./4. Liga …         (league 4/5/6, Gruppen aus /api/groups)
├── WM Herren / WM Damen    (bleiben SwissTXT)
└── Cup (optional)
```

**Quelle & Konfiguration (neu, analog `swisstxt.yml`):** `sources_table` neuer Eintrag `SWISS_UNIHOCKEY` (id 4); `src/main/resources/sources/swissunihockey.yml`:
```yaml
swissunihockey:
  name: SWISS_UNIHOCKEY
  id: 4
  url: https://api-v2.swissunihockey.ch/api
  leagues:
    - name: UNIHOCKEY_LUPL_MEN      # = sports_table.name der Liga-Node
      league: 24
      game_class: 11
    - name: UNIHOCKEY_NLB_MEN
      league: 2
      game_class: 11
    - name: UNIHOCKEY_1LIGA_MEN
      league: 3
      game_class: 11
      groups: true                 # Gruppen aus /api/groups als Kind-Nodes
```
Liga-Nodes per Flyway-Migration anlegen (wie `V3_19__fix_floorball_hierarchy.sql`). Gruppen-Nodes dynamisch im Sync anlegen/aktualisieren (Upsert nach `name`, Vorbild: Organisations-Gruppen werden zur Laufzeit als Sport-Nodes erzeugt), damit Gruppeneinteilungen pro Saison keine Migration brauchen.

**Sync-Algorithmus (`SwissUnihockeyService`, täglich via `EventSyncJob`):**
1. `GET /api/seasons` → aktuelle Saison (highlight).
2. Pro Konfig-Liga: wenn `groups`, `GET /api/groups?season&league&game_class` → Gruppen-Nodes upserten; sonst Liga-Node selbst ist Ziel-Node.
3. Pro Ziel-Node: `GET /api/calendars?season&league&game_class&group=` (ICS, ganze Saison, 1 Request) → VEVENTs parsen: `UID game-<id>` → `events_table.id`, `DTSTART/DTEND` (TZ Europe/Zurich → `LocalDateTime`), `SUMMARY` «Heim - Gast (Res)» → Name + Teamnamen, `LOCATION`/`GEO` → Location, `URL`.
4. Teams aus den SUMMARYs upserten (`teams_table`, `teams_sports_table` an der Ziel-Node). Team-ID: Slug des Namens (stabil, in ICS vorhanden) oder einmalig per `/api/games?mode=list` die `team_detail`-IDs auflösen.
5. `filterPastEvents` wie bei SwissTXT; `storeSyncTime`.
Alternative zu ICS: `/api/games?mode=list` (JSON, aber Spieltag-weise über `slider` → ~30–40 Requests pro Node). ICS ist billiger und enthält Resultate.

**Entscheidungen, die zu treffen sind**
- L-UPL/NLA doppelt: SwissTXT liefert heute `UNIHOCKEY_NLA*`. Empfehlung: L-UPL Herren/Damen auf Swiss Unihockey umstellen (eine Quelle, keine doppelten Teams/Events), SwissTXT nur noch für WM; die Phasen-Nodes Qualifikation/Playoff entfallen dafür (oder aus DESCRIPTION ableiten).
- Tiefe: bis 1. Liga reicht fürs Erste (klein, stabil); 2.–4. Liga sind viele Gruppen (regional attraktiv, aber Volumen).
- Nutzungsbedingungen bei it@swissunihockey.ch bestätigen, Attribution im Event-Text («Daten: swiss unihockey», URL ist schon im Event).
- **SFL / Swiss Ice Hockey**: keine öffentlichen APIs (SFL-Daten exklusiv bei Stats Perform); bereits via SwissTXT abgedeckt.

## 3. E-Sport

| Quelle | Zugang & Limits | Abdeckung | Lizenz / Haken | Eignung |
|---|---|---|---|---|
| **PandaScore** | Free Plan 1'000 Req/h, kein Kreditkarte; «Fixtures Only» gratis (v): `/matches/upcoming`, `/tournaments/upcoming`, pro Spiel z. B. `/lol/matches/upcoming`; 50–100 pro Seite | LoL, CS2, Dota 2, Valorant, R6, Rocket League, OW, KoG, MLBB … inkl. Teams, Ligen, Streams | Non-Betting; kein Live/Historie im Free-Plan (egal für Kalender) | **Sehr hoch** |
| **Liquipedia API (LPDB/MediaWiki)** | Gratis nur für Education/Community, max. 1 Req/2 s, `action=parse` 1 Req/30 s, User-Agent mit Kontakt Pflicht (v); aktuell «nur Enterprise-Plan» im Umbau | Alle Spiele, Turniere, «Upcoming and ongoing matches» | Nicht-kommerziell, Redistribution ausgeschlossen (d) → für Synci heikel | Niedrig (Lizenz) |
| **esports-ics (snwfdhmp)** / smartcalendars.ai | Fertige ICS-Feeds, basieren auf Liquipedia | 50+ Spiele | Drittanbieter, Liquipedia-Lizenzproblem erbt sich | Nur als Referenz |
| **Riot/lolesports, HLTV, vlr.gg** | Nur inoffizielle Wrapper/Scraper (npm `hltv`, PyPI `hltv-async-api`) | LoL, CS2, Valorant | ToS-Risiko, Bannrisiko | Niedrig |
| **Abios, GRID, Bayes, Sportradar** | Enterprise/paid | Alles | Preis | Niedrig |
| API-Sports | 100 Req/Tag pro Sport-API | kein E-Sport | – | – |

## 4. Weitere Sportarten (Ergänzung zu SwissTXT/bestehenden Quellen)

| Quelle | Zugang & Limits | Abdeckung | Eignung |
|---|---|---|---|
| **football-data.org** | Free: 12 Wettbewerbe, 10 Calls/min, Spielpläne verzögert (d); 12 €/Mt mit Live | Top-Ligen Europa, CL, WM/EM | Hoch für Spielpläne |
| **OpenLigaDB** | Gratis, kein Key, kein offizielles Limit | Bundesliga, 2. BL, DFB-Pokal, weitere DE-Ligen | Hoch für DE-Fussball |
| **TheSportsDB** | Free Key, Limits widersprüchlich (30/min bis 500/Tag), crowd-sourced | Viele Ligen, Logos/Artwork | Mittel (Genauigkeit) |
| **Jolpica-F1** (`/ergast/f1/{season}`) | Gratis, kein Key, Ergast-kompatibel | F1-Kalender/Resultate 2025/26 | Hoch, falls F1-Quelle ersetzt werden soll |
| **OpenF1** | Gratis für Historie; Live/2026 teils 401 (d) | Telemetrie, Sessions | Niedrig für Kalender |
| **API-Sports (api-football, api-nba, api-nhl, api-formula-1 …)** | 100 Req/Tag pro API, alle Endpoints (v) | NBA, NFL, NHL, F1, Fussball … | Mittel (Limit pro Sport, reicht für täglichen Sync) |
| **Live Tennis API** | Free: 30/min, 100/Tag | ATP/WTA Fixtures | Mittel |
| **ESPN «hidden» API** | Inoffiziell, kein Key | UFC, NFL, NBA … Schedules | Niedrig (inoffiziell) |
| **motorsport-calendar (PyPI)** | Open-Source-Tool, 16 Serien als ICS | F1, WEC, GT … | Referenz für Quellen |
| MotoGP, WRC, Formel E, UCI-Radsport, Boxen | Keine offiziellen APIs/ICS gefunden | – | – |
| Datasport, Swiss Running, Ahotu (Laufevents) | Keine API; Ahotu hat schema.org-JSON im HTML | Laufkalender CH | Niedrig (Scraping) |

### NFL (American Football) – nicht bei SwissTXT; geprüft 13.10.2026 mit Live-Tests

| Quelle | Zugang & Limits | Was es liefert | Lizenz / Risiko | Eignung |
|---|---|---|---|---|
| **nflverse `schedules`-Release** (`https://github.com/nflverse/nflverse-data/releases/download/schedules/games.csv` bzw. `.csv.gz`, `.parquet`; Spiegel `nflverse/nfldata/data/games.csv`) | Kein Key, 1 Download (2,2 MB CSV / 0,5 MB gz), automatisch per GitHub Actions aktualisiert, wenn sich die Quelle (Lee Sharpes nfldata) ändert | Alle Spiele seit 1999; **2026: 272 REG-Spiele** mit `game_id` (`2026_07_NE_CHI`), `gameday`, `gametime` (**Eastern Time**, verifiziert gegen ESPN-UTC), `away_team`/`home_team` (Kürzel), `location` (Home/Neutral), `stadium`, `roof`, `espn`-ID, `gsis`-ID, Quoten, Resultate nach Spielende; Playoffs werden ergänzt, sobald bekannt | **CC-BY-4.0** (Repo-Lizenz), Attribution «Data: nflverse»; Community-Projekt (im Okt 2026 wurde das Release neu gebaut, Asset-Namen können wechseln → gz + Spiegel als Fallback) | **Sehr hoch** (einfach, lizenzsauber, 1 Request/Tag) |
| **ESPN «hidden» API** (`site.api.espn.com/apis/site/v2/sports/football/nfl/...`) | Kein Key, kein dokumentiertes Limit, `cache-control: max-age=8`; `/scoreboard?dates=2026&seasontype=2&week=7` (14 Events), `/teams/{id}/schedule?season=2026` (17 Events), `/teams` (32 Teams mit IDs, Logos); Datumsbereich-Abfrage über die ganze Saison schlug fehl → pro Woche (18 REG + 4 POST + 4 PRE) oder pro Team (32) abfragen | Events mit UTC-Kickoff, Status (`STATUS_SCHEDULED`), Venue inkl. Stadt/Land (auch Neutral-Sites wie Stade de France, Melbourne), Home/Away mit Team-IDs, Broadcasts (Prime Video, …), Week/Seasontype, Preseason/Playoffs inkl. Super Bowl | Inoffiziell, keine ToS für Dritte, kann ohne Ankündigung ändern (Aug 2026 Berichte von 403 «You don't have permission» je nach Client; `site.web.api.espn.com` als Ausweichhost) | **Hoch als Zweitquelle** (TV-Sender, Playoffs, Live-Status) – nicht als einzige Grundlage |
| **API-Sports «API-American-Football»** | Free Key, 100 Req/Tag, 10/min, alle Endpoints (v), Saison = Startjahr | NFL + NCAA: Spiele, Teams, Standings, Odds | kommerziell nutzbar, zuverlässiger Anbieter; 100/Tag reicht für täglichen Sync (1 Call `/games?league=1&season=2026` für die ganze Saison) | **Hoch als stabile Alternative** (bezahlbarer Pro-Plan 15 $/Mt) |
| **BALLDONTLIE** | Free: 5 Req/min, Teams/Spieler/Games | NFL-Spielplan | Zahlungsmittel nur für Trial; Free reicht knapp | Mittel |
| **Big Balls Data** | Free 250 Req/Tag (500 mit GitHub) | `/v1/nfl/games`, teils «PENDING»-Felder | jung, unklar | Niedrig/Mittel |
| **MySportsFeeds** | gratis nur nicht-kommerziell/privat; Commercial ab 39 $/Mt | NFL Core-Feeds | Lizenz | Niedrig |
| **SportsDataIO** | Free nur letzte Saison; Trial ohne NFL | – | – | Niedrig |
| TheSportsDB | Free-Key liefert nur 15 nächste Events pro Liga, Limits widersprüchlich | – | – | Niedrig |
| nfl.com | kein offizieller API/ICS-Zugang | – | – | – |
| smartcalendars.ai, sportsbrackets.net | fertige ICS-Feeds (328 Events, 32 Team-Dateien), Zeiten in ET | Drittanbieter, Quelle ESPN | Nur Referenz |

**Empfehlung:** nflverse als Primärquelle (Spielplan, Teams, IDs, Resultate), ESPN als Anreicherung/Fallback (Playoffs vor nflverse-Update, Broadcasts, Live-Status), API-Sports als Plan B, falls beide Community-Quellen wegbrechen.

**Mapping in Synci:** `AMERICAN_FOOTBALL` → `NFL` (→ optional `NFL_REGULAR_SEASON` / `NFL_PLAYOFFS` analog zu `HOCKEY_*_QUALIFICATION/PLAYOFF`) → 32 Teams (`teams_table.id` = nflverse-Kürzel `NE`, `KC` …, `source_id` neu `NFLVERSE`), Events `id` = nflverse `game_id`, Name «Patriots at Bears», `starts_on` = `gameday` + `gametime` in `America/New_York` → `LocalDateTime` Europe/Zurich (bestehender Kalender nutzt statische Zeitzone), `ends_on` = +3 h 15 min, Location = `stadium`. Bye-Weeks aus ESPN `week.teamsOnBye` optional als ganztägiger Hinweis. Sync täglich: CSV laden, Zeilen `season == aktuelle Saison` upserten, `espn`-ID mitspeichern, um später ESPN-Details zu joinen.

### College Football (NCAA) – nicht in nflverse; geprüft 18.10.2026

nflverse enthält nur NFL (Spielplan mit 32 Teams, keine College-Releases). Umgesetzt ist **CollegeFootballData (CFBD)**:

| Quelle | Zugang & Limits | Was es liefert | Eignung |
|---|---|---|---|
| **CollegeFootballData** (`https://api.collegefootballdata.com`, OpenAPI v5.32.1) | Gratis-Key (collegefootballdata.com/key) als Bearer-Token, ohne Key 401; Free-Tier 1'000 Calls/Monat, Patreon ab 1 $/Mt 5'000 (Blog CFBD, Stand Saison 2025) | `GET /games?year=&seasonType=both&classification=fbs`: ganze Saison in **einem** Call; `id`, `startDate` (UTC), `startTimeTBD`, `seasonType`, Heim/Gast mit ID, Conference, Classification, `notes` (Bowl-Name), Venue, Resultate | **Primärquelle** (1 Call pro Sync ≈ 60/Monat) |
| API-Sports «API-American-Football» | siehe NFL oben, deckt NCAA ab | | Plan B |
| ESPN «hidden» API (`.../football/college-football/...`) | inoffiziell | | Fallback |

**Umsetzung in Synci:** Quelle `CFBD`, nur FBS. Baum `AMERICAN_FOOTBALL → NCAA_FOOTBALL («College Football») → NCAA_CONF_<Conference>` (im Sync erzeugt) und `NCAA_POSTSEASON` («Bowls & Playoff»). Reguläre Spiele hängen an der Conference des Heimteams (FCS-Gastgeber → Conference des FBS-Gasts, ohne Conference → «FBS Independents»); jedes FBS-Team ist an seine Conference gebunden, damit ein Team-Abo auch Auswärts- und Bowl-Spiele findet. Spiele mit `startTimeTBD` werden erst übernommen, wenn die Anstosszeit feststeht. Key über `CFBD_TOKEN`; ohne Key wird der Sync übersprungen.

## 5. Feiertage, Schulferien

| Quelle | Zugang | Abdeckung | Lizenz | Eignung |
|---|---|---|---|---|
| **OpenHolidays API** (openholidaysapi.org) | Kein Key, JSON + **iCal**, Filter Land/Kanton/Zeitraum (max. 3 Jahre)/Sprache | CH Feiertage + Schulferien ab 2020, 26 Kantone, teils pro Schultyp; künftige Jahre teils lückenhaft | CC BY 4.0 | **Sehr hoch** |
| Nager.Date v3 | Gratis (V1/V2 abgeschaltet) | 100+ Länder, nationale Ebene | MIT | Mittel (keine Kantone) |
| fcal.ch | Gratis privat, Business kostenpflichtig | Gemeinde-Ebene | proprietär | Niedrig |
| Calendarific, Abstract | Paid Tiers, Kantonsabdeckung unbelegt | – | – | Niedrig |

## 6. Film, Serien, Games, Raumfahrt (neue Kategorie «Releases & Co.»)

| Quelle | Zugang | Abdeckung | Lizenz | Eignung |
|---|---|---|---|---|
| **TVmaze API** | Kein Key, ≥20 Calls/10 s pro IP | Serien-Schedule pro Land/Tag, Episoden | CC BY-SA | Hoch |
| **TMDB API** | Free Key, Attribution | Kinostarts (`/movie/upcoming`), Serien | Attribution | Hoch |
| **IGDB (Twitch)** | Free (Twitch-Dev-Agreement), `release_dates`-Endpoint | Game-Releases, Plattform-Filter | kommerziell erlaubt (d) | Hoch |
| RAWG | 20'000 Req/Monat, nur nicht-kommerziell, Backlink | Games | Nicht-kommerziell | Niedrig |
| **AniList GraphQL** | Gratis | Anime-Airing-Schedule | – | Mittel (Nische) |
| **Launch Library 2** (`ll.thespacedevs.com/2.x/launch/upcoming/`) | Kein Key, 15 Req/h anonym, mehr via Patreon; eigene ICS-Feeds | Raketenstarts, Raumfahrt-Events | frei | Hoch (Nische, cachen) |
| Steam/Nintendo/PlayStation | Keine Release-Kalender-API (nur Scraper) | – | – | – |
| **SRG SSR EPG v3** | Registrierung, nicht-kommerziell (d) | TV/Radio-Programm SRF/RSI/RTS | nicht-kommerziell | Niedrig/Mittel («Sport im TV» wäre spannend, Lizenz prüfen) |

## 7. Technische Hinweise für eine Integration in Synci

- Alle Kandidaten liefern Listen mit Start/Ende/Ort/Name → passen in das bestehende Modell `Sport → subSports → Events/Teams` (vgl. `backend/.../data/sport`, Parser-Muster in `backend/src/main/resources/sources`). E-Sport: Spiel = Sport, Liga/Turnier = subSport, Team = Team, Match = Event. Feiertage: Kanton = subSport, ohne Teams.
- Tägliche Sync-Jobs (wie `feature/daily-sync`) reichen für alle Quellen; Live-Daten sind nirgends nötig. Damit sind selbst 15 Req/h (Launch Library) oder 100 Req/Tag (API-Sports) ausreichend, wenn pro Quelle gecacht wird.
- Lizenz-Checkliste vor dem Bau: (1) Weiterverbreitung als iCal erlaubt? (2) Attribution im Event-Beschreibungstext (Ticketmaster, TMDB, OpenHolidays CC BY). (3) Nicht-kommerziell-Klauseln (Liquipedia, JamBase, RAWG, SRG) → meiden oder Rücksprache.
- Offene Punkte, die nur mit Key/Kontakt zu klären sind: Eventfrog-Nutzungsbedingungen und Limits; Ticketmaster-Volumen für CH; Switzerland-Tourism-Event-Volumen; Katalog auf openeventdata.ch (Schnittstellen-Seite manuell öffnen).

## Quellen

- Ticketmaster: https://developer.ticketmaster.com/products-and-docs/apis/discovery-api/v2/ , https://developer.ticketmaster.com/products-and-docs/apis/discovery-feed/ , https://tickets.dev/guides/ticketmaster-discovery-api
- Eventfrog: https://eventfrog.ch/de/kooperationen/api-schnittstelle.html , https://docs.api.eventfrog.net/#publicapi-v1 , https://eventfrog.ch/de/help/organizer/settings/api/api-keys.html , https://www.openeventdata.ch/en/provider/eventfrog-53.html
- Switzerland Tourism / discover.swiss: https://developer.myswitzerland.io/ , https://docs.discover.swiss/dev/ , https://github.com/malkreide/discover-swiss-mcp
- PandaScore: https://developers.pandascore.co/docs/introduction , https://www.pandascore.co/pricing
- Liquipedia: https://liquipedia.net/api-terms-of-use , https://liquipedia.net/api ; esports-ics: https://github.com/snwfdhmp/esports-ics
- JamBase: https://data.jambase.com/pricing ; Bandsintown: https://corp.bandsintown.com/data-applications-terms ; SeatGeek: https://seatgeek.github.io/
- Eventbrite: https://github.com/Automattic/eventbrite-api/issues/83 ; Songkick: https://www.songkick.com/developer ; AllEvents: https://developer.allevents.in/ ; Meetup: https://github.com/api-evangelist/meetup ; PredictHQ: https://www.predicthq.com/pricing ; Luma: https://help.lu.ma/p/luma-api
- OpenHolidays: https://www.openholidaysapi.org/en/ ; fcal.ch: https://www.feiertagskalender.ch/api/schulferien-api-schweiz/index.php?hl=de ; Nager.Date: https://github.com/nager/Nager.Date
- Sport: https://dev.to/leomarsh886/a-survey-of-public-apis-for-building-a-football-live-score-site-in-2026-part-3-football-data-api-16hi , https://www.thestatsapi.com/blog/free-football-api-alternatives , https://github.com/jolpica/jolpica-f1/blob/main/docs/README.md , https://openf1.org/docs/ , https://www.api-football.com/news/post/how-to-get-started-with-api-football-the-complete-beginners-guide , https://livetennisapi.com/subscribe/free , https://api-v2.swissunihockey.ch/api/leagues/doc , https://www.svgeurope.org/blog/news-roundup/swiss-football-league-selects-stats-perform-as-official-data-partner/
- Releases/Space: https://thespacedevs.com/llapi , https://api-docs.igdb.com/ , https://rawg.io/apidocs , https://docs.anilist.co/reference/object/airingschedule , https://apideposu.com/en/blog/best-free-movie-tv-apis , https://pypi.org/project/motorsport-calendar/
- Schweiz Open Data: https://opendata.swiss/de/dataset?res_format=API , https://opendatazurich.github.io/ , https://data.bs.ch/explore/dataset/100057/api/ , https://developer.srgssr.ch/api-catalog , https://www.openeventdata.ch/en/
- Ticketing CH: https://blog.ticketino.com/kostenlose-rest-api-schnittstelle-fuer-veranstalter , https://www.ticketcorner.ch/campaign/ticketcheck
- College Football: https://apinext.collegefootballdata.com , https://blog.collegefootballdata.com/api-v2-is-now-in-general-availability/
- UFC-Feed (ESPN): https://www.smartcalendars.ai/en/feeds/ufc-schedule ; Laufen: https://www.ahotu.com/calendar/running/switzerland
