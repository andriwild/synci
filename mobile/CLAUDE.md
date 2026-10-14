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
Login only works once `AUTH0_CLIENT_ID` of the native Auth0 application is set.

## Conventions

- UI texts in German (Swiss spelling, "ss" instead of "ß"), addressing the user with "du".
- Code comments in English only, short and precise, and only when necessary (no German comments).
- State: Riverpod 3 without code generation (`Provider`, `FutureProvider`, `Notifier`, `AsyncNotifier`). Retry is disabled in `ProviderScope`; screens show errors with "Erneut versuchen".
- Navigation: go_router with a `StatefulShellRoute` (tabs Sportarten / Meine Abos / Konto), see `lib/router.dart`.
- The backend wraps every response in a serialized `ResponseEntity` (`{body, statusCode, …}`) and reports errors with HTTP 200; `unwrapEnvelope` in `lib/core/api/api_client.dart` handles this.
- Abos are always saved as a whole (`PUT /syncconfigs/{id}` with all lists), based on the latest server response.
- Analytics events mirror `frontend/src/utils/analytics.ts`; never send personal data.
- Bundle ID / applicationId is `ch.synci.app`; the Auth0 callback scheme is `ch.synci.app` (see `android/app/build.gradle.kts`, `ios/Runner/Info.plist`).

## Proactive hot reload (official Flutter rule)

Whenever you edit or modify any `.dart` file under `lib/`:

1. Skip files outside `lib/` (e.g. `test/**`, `integration_test/**`) and changes that only touch comments, docstrings or whitespace.
2. Discover running app instances with the `dtd` tool of the Dart MCP server and connect.
3. Run `hot_reload` after changes to widgets (including `build` methods) or simple methods; run `hot_restart` after changes to fundamental logic, state initialization (`initState`), global/static state or `main()`.
