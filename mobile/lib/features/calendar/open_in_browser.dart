import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

const browserChannel = MethodChannel('ch.synci.app/browser');

/// Opens [uri] in the browser. On Android an app that claims the link would open
/// instead, e.g. Google Calendar for calendar.google.com, so the platform side picks
/// the browser.
Future<bool> openInBrowser(Uri uri) async {
  if (defaultTargetPlatform == TargetPlatform.android) {
    try {
      if (await browserChannel.invokeMethod<bool>('open', uri.toString()) ?? false) return true;
    } on Exception {
      // fall back to the system's choice below
    }
  }
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on PlatformException {
    return false;
  }
}
