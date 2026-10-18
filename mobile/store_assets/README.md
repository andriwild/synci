# Store assets

Screenshots, icon and feature graphic for the App Store and Google Play.

| File | Purpose |
|---|---|
| `capture.sh` | Captures the raw screenshots into `screens/<platform>/` with demo data (`test_driver/screenshots.dart`, real sports from dev.synci.ch) |
| `synci.json` | mokkr preset (internal tool in `~/repos/mokkr`): device frames, German headlines, output into `out/<platform>/` |
| `to_fastlane.sh` | Copies `out/` and `play/` into the fastlane folders |
| `play/icon.png`, `play/feature_graphic.png` | Play listing icon (512×512) and feature graphic (1024×500) |

`screens/` and `out/` are generated and not committed.

## Update the screenshots

```bash
./capture.sh ios <simulator-udid>      # iPhone 6.9", e.g. iPhone 18 Pro Max
./capture.sh android <adb-serial>      # 1080×2400, e.g. Pixel emulator
pnpm --dir ~/repos/mokkr mockup render --preset $PWD/synci.json
./to_fastlane.sh
(cd ../ios && bundle exec fastlane screenshots)
(cd ../android && bundle exec fastlane screenshots)
```

On iOS, reboot the simulator first if the status bar shows a "back to app" link.
The store texts live in `../ios/fastlane/metadata` and `../android/fastlane/metadata`, uploaded with `fastlane metadata`.
