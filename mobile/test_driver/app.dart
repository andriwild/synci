import 'package:flutter_driver/driver_extension.dart';
import 'package:synci/main.dart' as app;

/// Entry point with the Flutter Driver extension, e.g. for the Dart MCP server:
/// `flutter run -t test_driver/app.dart --dart-define-from-file=config/local.json`
void main() {
  enableFlutterDriverExtension();
  app.main();
}
