# Synci mobile app (Flutter)

Flutter app for iOS and Android with the same features as the web frontend in `../frontend`.
It talks to the same Spring backend (`../backend`, REST under `/api`) and logs in through Auth0 (`account.synci.ch`).

## Run

```bash
flutter run --dart-define-from-file=config/local.json   # local backend on :8080 (Android emulator: 10.0.2.2)
flutter run --dart-define-from-file=config/dev.json     # dev.synci.ch
flutter test
```

`config/<stage>.json` holds the runtime config (`BACKEND_URL`, `AUTH0_*`, `UMAMI_*`), see `lib/config/env.dart`.
`AUTH0_CLIENT_ID` is the client ID of the native Auth0 application "Synci App".

## Release

Fastlane, run from `ios/` or `android/` with `bundle exec fastlane <lane>` (lanes and setup in `README.md`). Builds use `config/prod.json`; the build number is shared by both stores.

Credentials live outside the repo, never commit or print them:

- Android upload key: `~/.android/synci-upload.jks` (alias `upload`), referenced by `android/key.properties` (gitignored, holds the passwords). Without `key.properties` the Android build lanes stop.
- App Store Connect API key: `~/.fastlane/AuthKey_7AHDF9BDTX.p8`, also used for iOS signing (`-allowProvisioningUpdates`). The key has the Admin role, which cloud signing needs.
- Play service account: `~/.fastlane/klikkr-play.json` (`fastlane-klikkr@klikkr-fastlane.iam.gserviceaccount.com`, shared with Klikkr).

## Conventions

- UI texts in German (Swiss spelling, "ss" instead of "ß"), addressing the user with "du".
- Code comments in English only, short and precise, and only when necessary (no German comments).
- State: Riverpod 3 without code generation (`Provider`, `FutureProvider`, `Notifier`, `AsyncNotifier`). Retry is disabled in `ProviderScope`; screens show errors with "Erneut versuchen".
- Navigation: go_router with a `StatefulShellRoute` (tabs Start / Meine Abos / Organisationen / Konto), see `lib/router.dart`. The start screen (`/sport`) shows the root sports and my organisations as tiles; a tile with leagues or groups opens their tree (`/sport/sportart/:rootId`), the detail is `/sport/:sportId` or `/sport/sportart/:rootId/:sportId`. Navigate with `context.go` along this nesting, `push` would hide the screen from the analytics.
- Start: `SplashGate` (`lib/features/start/splash.dart`) continues the native splash with the vector logo (`SynciLogo`) and turns its sync arrows until auth, sports and organisations are loaded (at most 4 s). On the first start the intro story (`/willkommen`) follows; it can be opened again from Konto. Widget tests that pump `SynciApp` override `onboardingSeenProvider`; while the intro logo turns, use `pump` with durations instead of `pumpAndSettle`.
- The backend wraps every response in a serialized `ResponseEntity` (`{body, statusCode, …}`) and reports errors with HTTP 200; `unwrapEnvelope` in `lib/core/api/api_client.dart` handles this.
- Abos are always saved as a whole (`PUT /syncconfigs/{id}` with all lists), based on the latest server response.
- Analytics events mirror `frontend/src/utils/analytics.ts`; never send personal data.
- Bundle ID / applicationId is `ch.synci.app`; the Auth0 callback scheme is `ch.synci.app` (see `android/app/build.gradle.kts`, `ios/Runner/Info.plist`).

## Proactive hot reload (official Flutter rule)

Whenever you edit or modify any `.dart` file under `lib/`:

1. Skip files outside `lib/` (e.g. `test/**`, `integration_test/**`) and changes that only touch comments, docstrings or whitespace.
2. Discover running app instances with the `dtd` tool of the Dart MCP server and connect.
3. Run `hot_reload` after changes to widgets (including `build` methods) or simple methods; run `hot_restart` after changes to fundamental logic, state initialization (`initState`), global/static state or `main()`.
