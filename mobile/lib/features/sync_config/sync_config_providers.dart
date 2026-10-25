import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import 'sync_config.dart';
import 'sync_config_repository.dart';

final syncConfigsProvider = AsyncNotifierProvider<SyncConfigsController, List<SyncConfig>>(SyncConfigsController.new);

class SyncConfigsController extends AsyncNotifier<List<SyncConfig>> {
  SyncConfigRepository get _repository => ref.read(syncConfigRepositoryProvider);

  List<SyncConfig> get _current => state.value ?? const [];

  @override
  Future<List<SyncConfig>> build() async {
    final user = await ref.watch(authControllerProvider.future);
    if (user == null) return const [];
    return _repository.getAll();
  }

  Future<SyncConfig> create(String name) async {
    final created = await _repository.create(name);
    _set([..._current, created]);
    return created;
  }

  Future<SyncConfig> save(SyncConfig config) async {
    final saved = await _repository.update(config);
    _set([for (final c in _current) c.id == saved.id ? saved : c]);
    return saved;
  }

  Future<void> delete(SyncConfig config) async {
    await _repository.delete(config.id);
    _set([
      for (final c in _current)
        if (c.id != config.id) c,
    ]);
  }

  void _set(List<SyncConfig> configs) {
    if (ref.mounted) state = AsyncData(configs);
  }
}
