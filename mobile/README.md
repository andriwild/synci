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

## Icon and splash screen

The sources in `assets/icon/` are made from the website logo (`frontend/public/android-chrome-512x512.png`) without the text.
After changing them, regenerate the native files:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Both tools rewrite `ios/Runner/Info.plist` and `ios/Runner.xcodeproj/project.pbxproj`; revert those changes (`git checkout`), they are not needed.

## Release

Releases run through Fastlane from a developer machine, run from `ios/` or `android/`:

```bash
bundle exec fastlane beta              # TestFlight / Play internal test track (draft)
bundle exec fastlane beta track:alpha  # Android: closed test track
bundle exec fastlane release           # draft on the App Store / Play production
bundle exec fastlane release_live      # submit for review / publish directly
bundle exec fastlane metadata          # store texts from fastlane/metadata only
```

The build lanes check `config/prod.json`, take the next build number from TestFlight and Play together and build with `--dart-define-from-file=config/prod.json`.

Credentials (shared with Klikkr, same Apple team and Play developer account):

| File | Override |
|---|---|
| `~/.fastlane/AuthKey_7AHDF9BDTX.p8` (App Store Connect API key) | `APP_STORE_CONNECT_API_KEY_PATH` |
| `~/.fastlane/klikkr-play.json` (Play service account) | `GOOGLE_PLAY_JSON_KEY_FILE` |

`bundle exec fastlane validate` checks both.

Before the first release:

- Android:
    - Create an upload key and `android/key.properties` (`storeFile`, `storePassword`, `keyAlias`, `keyPassword`; both gitignored). Without it the build lanes stop.
    - Create the app `ch.synci.app` in the Play Console and upload the first bundle by hand; Play only accepts API uploads after that.
    - Give the Play service account access to the app (Users and permissions).
    - Enable Play App Signing and fill in the Data safety form.
    - Private developer accounts created after 13 Nov 2023 need a closed test with at least 12 testers for 14 consecutive days before production.
- iOS:
    - Create the app `ch.synci.app` in App Store Connect.
    - Fill in App Privacy (email, name and user ID for app functionality; anonymous usage data; no tracking).
    - Upload screenshots (the app is iPhone-only).
- Both:
    - Privacy policy URL `https://synci.ch/datenschutz`, account deletion link `https://synci.ch/faq`.
    - An email/password demo account for the reviewers, entered in the store consoles (not in the repo).
