# SEO-Optimierung synci.ch, ganzheitlicher Plan

## Kontext

synci.ch ist eine React/Vite-Single-Page-App (Branch `dev`), die hinter Caddy und nginx ausgeliefert wird. Der Audit zeigt: Suchmaschinen finden heute praktisch nichts Verwertbares. Jede URL liefert dasselbe leere HTML mit `<title>Sync!</title>`, `lang="en"`, ohne Beschreibung, ohne Social-Tags, ohne robots.txt und Sitemap. Sportnamen stehen erst nach einem API-Call im DOM, Navigation läuft über `onClick` statt Links, es gibt keine 404-Seite, kein Impressum, keinen Datenschutz, und das JavaScript-Bundle (1.27 MB) wird unkomprimiert ausgeliefert. Die Dev-Instanz ist öffentlich und indexierbar.

Ziel: Dass Synci für Suchanfragen wie „Super League Spielplan Kalender“, „Eishockey Termine Google Kalender“, „Skirennen iCal“ gefunden wird, die Startseite in Social-Previews gut aussieht und die technische Basis (Core Web Vitals, Crawlbarkeit) stimmt. Dieser Plan ordnet alle Massnahmen nach Aufwand und Wirkung; Phase 1 ist direkt umsetzbar, Phase 2 und 3 sind Roadmap.

**Annahmen:** Zielmarkt Deutschschweiz, Sprache Deutsch (keine Mehrsprachigkeit in diesem Plan). Umami-Tracking existiert nur auf `main`, nicht auf `dev`.

## Ist-Zustand (Audit, Kurzfassung)

| Bereich | Befund |
|---|---|
| `frontend/index.html` | `lang="en"`, Titel „Sync!“, keine Description, keine OG/Twitter-Tags, kein Canonical, kein Manifest-Link, Favicon mit falschem MIME-Typ, Google Fonts mit allen Schnitten 100–900 render-blockierend, `config.js` synchron |
| Routing | `BrowserRouter`, keine 404-Route, keine Titel pro Seite, keine URL pro Sportart, alle Links per `onClick` |
| `frontend/public` | kein `robots.txt`, keine `sitemap.xml`, `site.webmanifest` leer, kein OG-Bild, 1.08 MB `fan_hero.png` und sechs `synci_preview*.png` (bis 1.79 MB) ungenutzt mitdeployt |
| Inhalte | Startseite mit h1 und wenig Text, FAQ ist Platzhalter, Footer-Links „Datenschutz/Impressum/FAQ“ führen alle auf `/faq`, kein Impressum, keine Datenschutzerklärung |
| Server | nginx ohne gzip und Cache-Header, Caddy ohne `encode`, kein www-Redirect, Port 80 nicht gemappt, `/dashboard` und `/metrics` öffentlich, `dev.synci.awild.ch` indexierbar, `debug` aktiv |
| Performance | ein JS-Chunk 1.27 MB (≈390 KB gzip, aber unkomprimiert geliefert), kein Code-Splitting, Hero-JPG 175 KB mit `alt=""` und falschen Dimensionen |
| Backend | `GET /api/sports` und Events öffentlich; kein serverseitiges HTML |

## Phase 1: Low hanging fruits (1 bis 2 Tage, hohe Wirkung)

### 1.1 Head und Meta (`frontend/index.html`)
- `lang="de"`, `<title>` mit Default „Synci – Sport-Termine automatisch im Kalender“, `meta description`, `theme-color`, `link rel="manifest"`, `apple-touch-icon`, Favicon-Typ korrigieren.
- Open Graph und Twitter Card (title, description, `og:image` 1200×630, `og:url`, `og:locale=de_CH`, `twitter:card=summary_large_image`). OG-Bild aus einem bestehenden `synci_preview*.png` erzeugen und als `public/og-image.jpg` (< 200 KB) ablegen.
- `site.webmanifest` füllen (name, short_name, theme_color `#3D5A80`, background, icons).
- Google Fonts auf die genutzten Schnitte reduzieren (400, 500, 600, 700, kein italic), `preload` für die CSS-Datei, `config.js` mit `defer` laden (nur wenn `env.ts` das verträgt, sonst belassen).

### 1.2 Seitentitel und Description pro Route
- Neuer Hook `frontend/src/utils/usePageMeta.ts` (`title`, `description`, `canonical`, optional `noindex`) ohne zusätzliche Library: setzt `document.title`, aktualisiert `meta[name=description]`, `link[rel=canonical]`, `meta[name=robots]`.
- Einsatz in `HomePage`, `SportPage`, `FaqPage`, `OrganisationsPage`, `OrganisationMembersPage` (noindex), `SyncConfigPage` (noindex), neue `NotFoundPage`.

### 1.3 Echte Links und 404
- `Header.tsx`: Menü-Items mit `label: <Link to="/sport">Sportarten</Link>`, Logo in `<Link to="/">`. `Footer.tsx`, `PreHeader.tsx`, CTA-Buttons in `FirstImpressionComponent`/`AvailableSportsComponent`: `Link`/`href` statt `onClick`-`navigate`.
- Catch-all `<Route path="*" element={<NotFoundPage/>}/>` mit Titel „Seite nicht gefunden“, `noindex` und Links zurück. nginx kann für eine SPA keinen 404 liefern; das `noindex` verhindert Soft-404-Indexierung.

### 1.4 robots.txt und statische Sitemap (`frontend/public`)
- `robots.txt`: `User-agent: *`, `Disallow: /syncConfig`, `/organisationen`, `Sitemap: https://synci.ch/sitemap.xml`.
- `sitemap.xml` statisch mit `/`, `/sport`, `/faq`, `/impressum`, `/datenschutz` (Phase 2 ersetzt sie durch die dynamische Sitemap).

### 1.5 Dev-Instanz und Duplikate aussperren (`infrastructure/config/Caddyfile`)
- Block `dev.synci.awild.ch`: `header X-Robots-Tag "noindex, nofollow"`.
- Neuer Block `www.synci.ch { redir https://synci.ch{uri} permanent }`.
- `infrastructure/docker-compose.yml`: Port `80:80` mappen, damit Caddy HTTP→HTTPS umleitet.
- `/dashboard*` und `/metrics` nicht mehr auf `synci.ch` routen (nur `dashboard.synci.awild.ch`), `debug` entfernen.

### 1.6 Kompression und Caching
- Caddy: `encode zstd gzip` in allen Site-Blocks.
- `frontend/default.conf`: `gzip on` für JS/CSS/SVG/JSON, `location /assets/ { expires 1y; add_header Cache-Control "public, immutable"; }`, `index.html` mit `no-cache`, `server_name _`.

### 1.7 Bilder und Überschriften
- Hero: `fan_hero.jpg` nach WebP (≈40 KB) und AVIF konvertieren, `<picture>` mit Fallback, `width="1456" height="816"`, aussagekräftiges `alt`, `fetchpriority="high"`.
- Ungenutzte Assets aus `public/assets` entfernen (`fan_hero.png`, `synci_preview*.png`, `vite.svg`); das OG-Bild bleibt.
- Tutorial-Screenshots: `alt`-Texte, Schritt-Titel als h3 statt h5. `/sport` bekommt ein visuell verstecktes h1 „Sportarten und Ligen“. Organisations- und Abo-Seiten starten mit h1/h2.

### 1.8 Messung einrichten
- Google Search Console und Bing Webmaster Tools für synci.ch verifizieren (DNS-TXT oder Meta-Tag), Sitemap einreichen.
- Lighthouse-Baseline vor und nach Phase 1 festhalten (Performance, SEO, Accessibility).

## Phase 2: Mittlerer Aufwand (1 bis 2 Wochen)

### 2.1 Pflichtseiten und echter Inhalt
- Neue Routen `/impressum`, `/datenschutz` (Texte vom Betreiber), `/so-funktionierts` (Tutorial als eigene Seite mit vollständigem Text aller Schritte im DOM, nicht nur der aktive Schritt).
- FAQ mit 10 bis 15 echten Fragen („Wie abonniere ich die Super League in Google Kalender?“, „Wie oft aktualisieren sich Termine?“, „Ist Synci kostenlos?“). Antworten als Text im DOM plus JSON-LD `FAQPage`.
- Footer-Links korrekt verdrahten.

### 2.2 Indexierbare Sport-URLs
- Backend: Spalte `slug` in `sports_table` (Migration; aus `label` generiert, eindeutig innerhalb des Elternknotens), `GET /api/sports` liefert `slug`; neu `GET /api/sports/by-path/{slugPath}` oder Auflösung clientseitig aus dem Baum.
- Frontend: Route `/sport/:slugPath*` (z.B. `/sport/fussball/schweizerligen/super-league`), Tree-Auswahl aus der URL ableiten und beim Klick die URL setzen (shareable Links, Browser-Back funktioniert). Titel/Description pro Sportart aus dem Hook: „Super League Spielplan als Kalender-Abo | Synci“.
- Organisationen bleiben ausgeschlossen (nur Member).

### 2.3 Dynamische Sitemap
- Backend `GET /api/sitemap.xml` (öffentlich) aus statischen Seiten plus allen Sportarten ohne `organisation_id` mit `lastmod` aus dem letzten Sync. Caddy: `handle /sitemap.xml { reverse_proxy backend }`. Statische Sitemap aus Phase 1 entfällt.

### 2.4 Strukturierte Daten
- JSON-LD auf der Startseite: `Organization` + `WebSite` (mit `SearchAction` erst, wenn es eine Suche gibt) und `SoftwareApplication`.
- `FAQPage` auf `/faq`. `BreadcrumbList` auf Sport-Seiten.
- `SportsEvent` pro Event erst mit Prerendering (Phase 3), sonst sieht Google sie zu spät.

### 2.5 Performance und Core Web Vitals
- `React.lazy` + `Suspense` pro Route in `App.tsx`; `vite.config.ts` `build.rollupOptions.output.manualChunks` für `antd`, `@tabler/icons-react`, `@phosphor-icons/react`, `@auth0`.
- Eine der zwei Icon-Bibliotheken ablösen, `@react-oauth/google` entfernen.
- Montserrat selbst hosten (woff2, nur genutzte Schnitte, `font-display: swap`), Google-Fonts-Abhängigkeit entfernen.
- Auth0-Token-Abruf nicht mehr auf der Startseite blockierend (nur wenn `isAuthenticated`), `updateMe` nur einmal pro Sitzung.
- Ziel: LCP < 2.5 s mobil, JS initial < 300 KB gzip.

### 2.6 Analytics zusammenführen
- Umami von `main` nach `dev` mergen (bereits DSGVO-freundlich ohne Cookies), Events für „Abo erstellt“, „Kalender hinzugefügt“ als Conversion-Ziele in der Search-Console-Auswertung nutzen.

## Phase 3: Aufwendig (mehrere Wochen, grösster Hebel)

### 3.1 Prerendering der öffentlichen Seiten
- Zur Build-Zeit statisches HTML für `/`, `/faq`, `/so-funktionierts`, `/impressum`, `/datenschutz` und alle `/sport/...`-Seiten erzeugen (z.B. `vite-react-ssg` oder ein eigenes Prerender-Skript mit `renderToString`), Sportbaum und die nächsten Events pro Sportart dabei vom Backend laden. Ergebnis: Crawler und Social-Bots sehen Inhalt, Titel und OG-Tags ohne JavaScript.
- Deploy-Pipeline: Frontend-Build nach jedem Daten-Sync bzw. täglich neu bauen, oder die Sport-Seiten nicht statisch, sondern über einen kleinen Node-Prerender-Service für Bot-User-Agents ausliefern (Caddy `@bot header User-Agent *Googlebot*` → Prerender). Entscheidung hängt davon ab, wie aktuell Event-Listen im HTML sein müssen; für Rankings reicht täglicher Rebuild.
- Alternative mit höchstem Aufwand: Migration auf ein SSR-Framework (Next.js, Remix). Nur sinnvoll, wenn die App ohnehin neu strukturiert wird.

### 3.2 Event-Detailseiten mit `SportsEvent`-Schema
- Route `/event/:source/:id` mit Titel „Team A – Team B, 20.11.2026 | Synci“, JSON-LD `SportsEvent` (startDate, location, homeTeam/awayTeam) für Rich Results, Button „In Kalender“. Setzt 3.1 voraus.

### 3.3 Inhalte als Wachstumsmotor
- Landing-Pages pro Liga mit redaktionellem Text („Super League 2026/27: Spielplan, Termine, Kalender-Abo“), Saisoninfos, FAQ pro Liga. Das ist der eigentliche Ranking-Hebel für die Keywords; Technik aus 2.2/3.1 ist die Voraussetzung.
- Optional Blog/Guides („Google Kalender Abo einrichten“, „Outlook iCal“), interne Verlinkung zu den Liga-Seiten.

### 3.4 Mehrsprachigkeit
- Französisch/Italienisch für die Schweiz mit `hreflang`, Routen-Präfix `/fr`, `/it`, Übersetzungen über i18n-Library. Nur wenn der Markt es verlangt.

## Reihenfolge und Abhängigkeiten

1. Phase 1 komplett (ein PR Frontend, ein PR Infrastruktur). Danach Search Console einreichen.
2. Phase 2 in der Reihenfolge 2.1 → 2.5 → 2.2 → 2.3 → 2.4 → 2.6. 2.2 ist Voraussetzung für 2.3, 2.4 und alles in Phase 3.
3. Phase 3 nach messbarem Effekt von 1 und 2 (Impressionen in der Search Console), beginnend mit 3.1.

## Verifikation

- Nach Phase 1: `curl -sI https://synci.ch` zeigt `content-encoding`, Cache-Header; `curl https://synci.ch/robots.txt` und `/sitemap.xml` liefern Inhalt; `curl -sI https://dev.synci.awild.ch` zeigt `X-Robots-Tag: noindex`; `curl -sI https://www.synci.ch` liefert 301 auf `https://synci.ch`.
- `view-source` der Startseite: `lang="de"`, Titel, Description, OG-Tags vorhanden. Facebook Sharing Debugger / LinkedIn Post Inspector zeigen Bild und Text.
- Lighthouse mobil: SEO-Score ≥ 95, Performance deutlich über Baseline, keine „Links are not crawlable“-Meldung.
- Google Rich Results Test auf `/faq` (Phase 2) und Event-Seiten (Phase 3).
- Search Console: Abdeckung ohne „Soft 404“, Sitemap verarbeitet, Impressionen pro Liga-Seite als KPI.
