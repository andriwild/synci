import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/auth/auth_controller.dart';
import 'sync_config.dart';

final syncConfigRepositoryProvider = Provider((ref) => SyncConfigRepository(ref.read(apiClientProvider)));

class SyncConfigRepository {
  const SyncConfigRepository(this._api);

  final ApiClient _api;

  Future<List<SyncConfig>> getAll() async {
    final body = await _api.get('syncconfigs') as List<dynamic>;
    return [for (final json in body) SyncConfig.fromJson(json as Map<String, dynamic>)];
  }

  Future<SyncConfig> create(String name) async {
    final body = await _api.post('syncconfigs', {'name': name, 'sports': [], 'teams': [], 'events': []});
    return SyncConfig.fromJson(body as Map<String, dynamic>);
  }

  Future<SyncConfig> update(SyncConfig config) async {
    final body = await _api.put('syncconfigs/${config.id}', config.toRequestJson());
    return SyncConfig.fromJson(body as Map<String, dynamic>);
  }

  Future<void> delete(String id) => _api.delete('syncconfigs/$id');
}
