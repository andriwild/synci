import 'package:synci/features/app_update/app_update_repository.dart';

class FakeAppUpdateRepository implements AppUpdateRepository {
  FakeAppUpdateRepository({this.available = false, this.updateFails = false});

  final bool available;
  final bool updateFails;
  int checks = 0;
  int updates = 0;

  @override
  Future<bool> isUpdateAvailable() async {
    checks++;
    return available;
  }

  @override
  Future<void> update() async {
    updates++;
    if (updateFails) throw const AppUpdateException('denied');
  }
}
