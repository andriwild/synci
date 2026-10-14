# E-Sport-Datenquellen für Synci

Stand: 14. Oktober 2026. Ziel: Spielpläne von E-Sport-Ligen und -Turnieren als abonnierbare Kalender. Bewertet nach Zugang, Kosten, Abdeckung, Lizenz (Synci gibt die Daten als iCal weiter) und Stabilität. «Live getestet» heisst: am Stichtag mit echten Requests geprüft.

## Ergebnis

**Primärquelle: PandaScore (Free-Plan).** Einzige dokumentierte, stabile API, die Spielpläne für alle grossen Titel gratis liefert. Die inoffizielle Riot-API ist ein guter Fallback für League of Legends und Valorant.

| Quelle | Zugang & Kosten | Abdeckung | Lizenz / Risiko | Eignung |
|---|---|---|---|---|
| **PandaScore** (`api.pandascore.co`) | Account + Token. Free-Plan «Schedules, Results & Context» 0 €, 1'000 Requests/Stunde. Historical ab 400 € pro Spiel und Monat, Live ab 1'000 € | 13+ Spiele: LoL, CS2, Valorant, Dota 2, R6 Siege, Rocket League, Overwatch, Call of Duty, EA FC, MLBB, StarCraft, King of Glory, Wild Rift. Hierarchie Videogame → Liga → Serie → Turnier → Match; Teams, Streams, Turnier-Tier (S–D) | Dokumentiert und stabil. Stats-Pläne nicht für Wetten. Attribution und Weiterverbreitung sind in den öffentlich sichtbaren Bedingungen nicht geregelt → beim Anbieter bestätigen | **Primärquelle** |
| **Riot lolesports-API** (inoffiziell, `esports-api.lolesports.com/persisted/gw`) | Öffentlich bekannter `x-api-key` der lolesports-Website, keine Anmeldung | **Live getestet:** LoL mit 51 Ligen (WM, MSI, First Stand, LEC, LCK, LPL, LCS, Prime League, LFL …), `getSchedule` liefert 80 Events pro Seite mit Best-of und Team-Codes. **Valorant** über `esports-api.service.valorantesports.com/persisted/val` mit `sport=val` (Champions, Masters, VCT EMEA/Americas/Pacific/CN, Game Changers, Challengers) | Inoffiziell, keine SLA, kann jederzeit brechen. Riot-Entwicklerrichtlinien verbieten «Data Broker»-Nutzung | Fallback für LoL und Valorant |
| **Liquipedia LPDB** | Nur auf Antrag. Gratis nur für Bildung, Community und nicht-kommerzielle Projekte. 60 Requests/Stunde, 1 Request/2 s. Bezahlpläne laut Dritten ab 49 $/Monat. Scraping der HTML-Seiten verboten, Website hinter Captcha | Alle Spiele, sehr vollständig | CC-BY-SA 3.0, Attribution Pflicht | Nicht geeignet (Lizenz, Limits) |
| **GRID Open Access** | Antrag; gratis für Fans, Studierende, Projekte ohne Umsatz | CS2 und Dota 2, Fokus In-Game- und Matchdaten | Kommerzielle Nutzung nur für Partner | Niedrig |
| **FACEIT Data API** | Gratis-Key | Nur FACEIT-eigene Championships und Matches | – | Niedrig |
| **start.gg** (GraphQL) | Gratis-Token, 80 Requests/Minute | Fighting Games und Community-Turniere | – | Später, falls Fighting Games gewünscht |
| **OpenDota / STRATZ** | Gratis | Dota-2-Resultate; ein Spielplan existiert nur auf der STRATZ-Website, nicht dokumentiert in der API | – | Niedrig |
| **vlr.gg / HLTV** | Nur inoffizielle Scraper; vlrggapi-Instanz offline, HLTV blockt automatisierte Zugriffe | Valorant, CS2 | ToS-Risiko | Nicht geeignet |
| **Octane (Rocket League)** | **Live getestet:** `zsr.octane.gg` existiert nicht mehr (DNS NXDOMAIN) | – | – | Eingestellt |
| Abios, Bayes, Sportradar, Goalserve, Esport-API.com | Kommerziell: Goalserve 100 $/Monat, Esport-API 60 $/Monat, übrige auf Anfrage | breit | Kosten | Nicht nötig |
| Swiss Esports League, Swisscom Hero League | Keine API gefunden | Schweizer Szene | – | – |
| Fertige ICS-Feeds (smartcalendars.ai, esports-ics) | Gratis abonnierbar | basieren auf PandaScore bzw. Liquipedia | Drittanbieter | Nur Referenz |

## PandaScore im Detail

- **Auth:** `Authorization: Bearer <token>` (alternativ `?token=`).
- **Endpoint:** `GET /matches/upcoming` ist im Free-Plan verfügbar. Filter `filter[videogame]`, `filter[league_id]`, `range[scheduled_at]`, Sortierung `sort=scheduled_at`, Seiten `page`, `per_page` (max. 100).
- **Match-Felder:** `id`, `name`, `scheduled_at` (UTC), `begin_at`, `original_scheduled_at`, `rescheduled`, `status` (`not_started`, `running`, `finished`, `postponed`, `canceled`), `match_type`, `number_of_games`, `league{id,name,slug}`, `serie{full_name,year}`, `tournament{name,tier,region}`, `opponents[{type,opponent{id,name,acronym}}]`, `videogame{slug}`, `streams_list`.
- **Rate-Limit:** Header `X-Rate-Limit-Remaining`.

## Quellen

- PandaScore: https://www.pandascore.co/pricing , https://developers.pandascore.co/docs/introduction , https://developers.pandascore.co/docs/rate-and-connections-limits , https://developers.pandascore.co/reference/get_matches_upcoming
- Riot lolesports (inoffiziell): https://vickz84259.github.io/lolesports-api-docs/ , https://github.com/kingjakeu/lolesports/blob/main/doc/unofficial-riot-api-guide.md , Riot-Richtlinien: https://developer.riotgames.com/policies/general
- Liquipedia: https://liquipedia.net/api-terms-of-use , https://github.com/ben-domingue/irw/issues/2704
- GRID: https://grid.gg/open-access/
- FACEIT: https://docs.faceit.com/docs/data-api/data/
- start.gg: https://dev.start.gg/docs/rate-limits
- STRATZ/OpenDota: https://stratz.com/leagues/schedule , https://citoapi.com/blog/best-dota-2-api/
- vlr.gg: https://github.com/axsddlr/vlrggapi ; HLTV-Alternativen: https://github.com/topics/hltv-api
- Kommerzielle Anbieter: https://www.goalserve.com/en/sport-data-feeds/esports-api/prices , https://sportsapi.com/api-directory/esport-api/ , https://www.apisports.net/best/esports-apis
- Fertige ICS: https://smartcalendars.ai/en/feeds/league-of-legends-schedule , https://github.com/snwfdhmp/esports-ics
