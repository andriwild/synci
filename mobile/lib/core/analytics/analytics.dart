import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';

final analyticsProvider = Provider<Analytics>((ref) => Analytics());

/// No personal data (email, user ID, sync config names).
class Analytics {
  Analytics({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 5)));

  final Dio _dio;

  static const _hostname = 'app.synci.ch';

  bool get _enabled => !kDebugMode && Env.umamiUrl.isNotEmpty && Env.umamiWebsiteId.isNotEmpty;

  void screen(String path) => _send(url: path);

  void event(String name, [Map<String, Object?> data = const {}]) => _send(name: name, data: data);

  Future<void> _send({String? name, Map<String, Object?> data = const {}, String url = '/'}) async {
    if (!_enabled) return;
    final view = PlatformDispatcher.instance.implicitView;
    final size = view == null ? null : view.physicalSize / view.devicePixelRatio;
    final cleaned = {
      for (final entry in data.entries)
        if (entry.value != null && entry.value != '') entry.key: entry.value,
    };
    try {
      await _dio.post<void>(
        '${Env.umamiUrl}/api/send',
        data: {
          'type': 'event',
          'payload': {
            'website': Env.umamiWebsiteId,
            'hostname': _hostname,
            'url': url,
            'language': PlatformDispatcher.instance.locale.toLanguageTag(),
            if (size != null) 'screen': '${size.width.round()}x${size.height.round()}',
            'name': ?name,
            if (cleaned.isNotEmpty) 'data': cleaned,
          },
        },
        // Umami drops requests without a browser-like user agent as bots
        options: Options(headers: {'User-Agent': _userAgent}),
      );
    } on Exception {
      // Tracking must never break the app
    }
  }

  static final _userAgent = Platform.isIOS
      ? 'Mozilla/5.0 (iPhone; CPU iPhone OS like Mac OS X) SynciApp'
      : 'Mozilla/5.0 (Linux; Android) SynciApp';
}
