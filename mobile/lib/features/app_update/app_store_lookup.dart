import 'dart:convert';

import 'package:dio/dio.dart';

/// The version of the app on sale in the App Store and its store page.
typedef AppStoreListing = ({String version, Uri page});

/// Apple's public lookup. It only knows versions on sale, not TestFlight builds.
class AppStoreLookup {
  const AppStoreLookup(this._dio, {required this.bundleId});

  final Dio _dio;
  final String bundleId;

  /// `null` while the app is not on sale in Switzerland. Throws [DioException] or [FormatException].
  Future<AppStoreListing?> fetch() async {
    final response = await _dio.get<String>(
      'https://itunes.apple.com/lookup',
      queryParameters: {'bundleId': bundleId, 'country': 'ch'},
      // Apple answers with text/javascript, which Dio would not decode
      options: Options(responseType: ResponseType.plain),
    );
    return switch (jsonDecode(response.data ?? '')) {
      {'results': [{'version': final String version, 'trackViewUrl': final String url}, ...]} => (
        version: version,
        page: Uri.parse(url),
      ),
      {'results': []} => null,
      final other => throw FormatException('Unexpected App Store lookup', other),
    };
  }
}
