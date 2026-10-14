# Synci mobile app

Flutter app for iOS and Android with the same features as the web frontend: browse sports, leagues and teams, save them in Abos and subscribe to an Abo in the phone's calendar.
It uses the same backend (`/api`) and the same Auth0 tenant (`account.synci.ch`) as the website.

## Run locally

Requirements: Flutter (stable), Xcode for iOS, Android SDK for Android.

```bash
cd mobile
flutter pub get
flutter run --dart-define-from-file=config/local.json   # backend on localhost:8080
flutter run --dart-define-from-file=config/dev.json     # dev.synci.ch
flutter test
```

On the Android emulator, `localhost` is mapped to `10.0.2.2` automatically (`lib/config/env.dart`).
`test_driver/app.dart` starts the app with the Flutter Driver extension, so tools like the Dart MCP server can tap through it.

## Configuration

`config/<stage>.json` is passed with `--dart-define-from-file`:

| Key | Meaning |
|---|---|
| `BACKEND_URL` | Backend base URL with trailing slash, e.g. `https://synci.ch/` |
| `AUTH0_DOMAIN` | Auth0 custom domain, `account.synci.ch` |
| `AUTH0_CLIENT_ID` | Client ID of the **native** Auth0 application "Synci App" (empty = login disabled) |
| `AUTH0_AUDIENCE` | API identifier, `https://synci.ch/api` |
| `UMAMI_URL`, `UMAMI_WEBSITE_ID` | Anonymous analytics; empty = off (always off in debug builds) |

## Auth0 setup (one-time)

1. **API**: create an API with identifier `https://synci.ch/api` (RS256, allow offline access). Keep the old API `https://synci.awild.ch` until the website has switched over; the backend accepts both (`AUTH0_AUDIENCES`). For the website, add `https://synci.ch` and `https://dev.synci.ch` to "Allowed Web Origins" of the SPA application, so logged-in users silently get a token for the new audience.
2. **Native application "Synci App"**:
   - Allowed Callback URLs and Allowed Logout URLs:
     `ch.synci.app://account.synci.ch/ios/ch.synci.app/callback, ch.synci.app://account.synci.ch/android/ch.synci.app/callback`
   - Grant types: Authorization Code, Refresh Token; enable refresh token rotation and raise the refresh token lifetimes (the defaults log users out after 15 days of inactivity).
   - Connections: Username-Password, Google, Apple.
   - Make sure the application may request tokens for the new API.
   - Put the client ID into `config/*.json` (`AUTH0_CLIENT_ID`).
3. **Sign in with Apple** (required by App Store guideline 4.8 because Google login is offered): in the Apple Developer account create the App ID `ch.synci.app`, a Services ID with the return URLs `https://account.synci.ch/login/callback` and `https://<tenant>.<region>.auth0.com/login/callback`, and a Sign in with Apple key. Enter Team ID, Services ID, Key ID and the `.p8` key in the Auth0 Apple connection (not the Auth0 dev keys, so Auth0 revokes Apple tokens when an account is deleted).
4. **Machine-to-machine application "Synci Backend"** with only the `delete:users` scope on the Auth0 Management API. The backend needs `AUTH0_MGMT_DOMAIN` (the original `<tenant>.<region>.auth0.com` domain), `AUTH0_MGMT_CLIENT_ID` and `AUTH0_MGMT_CLIENT_SECRET` for `DELETE /api/users/me`.

## Release

```bash
flutter build ipa --dart-define-from-file=config/prod.json
flutter build appbundle --dart-define-from-file=config/prod.json
```

Before the first store submission:

- Android: create an upload key and a `signingConfig` for release builds (currently signed with the debug key), enable Play App Signing, fill in the Data safety form. Private developer accounts created after 13 Nov 2023 need a closed test with at least 12 testers for 14 consecutive days before production.
- iOS: create the app `ch.synci.app` in App Store Connect, fill in App Privacy (email, name and user ID for app functionality; anonymous usage data; no tracking), upload screenshots (the app is iPhone-only).
- Both: privacy policy URL (`https://synci.ch/impressum`), account deletion link (`https://synci.ch/faq`), and an email/password demo account for the reviewers.
