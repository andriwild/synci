import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synci/core/api/api_client.dart';
import 'package:synci/core/auth/auth_controller.dart';
import 'package:synci/core/auth/auth_service.dart';

void main() {
  Future<_RecordingApi> restore(AppUser? user) async {
    final api = _RecordingApi();
    final container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(_FakeAuthService(user)),
        apiClientProvider.overrideWithValue(api),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authControllerProvider.future);
    return api;
  }

  test('reports email and name to the backend after restoring the session', () async {
    final api = await restore(const AppUser(name: 'andri', email: 'andri@example.com', fullName: 'Andri Wild'));

    expect(api.paths, ['users/me']);
    expect(api.bodies.single, {'email': 'andri@example.com', 'name': 'Andri Wild'});
  });

  test('reports nothing without email or user', () async {
    expect((await restore(const AppUser(name: 'andri'))).paths, isEmpty);
    expect((await restore(null)).paths, isEmpty);
  });
}

class _FakeAuthService extends Fake implements AuthService {
  _FakeAuthService(this.user);

  final AppUser? user;

  @override
  Future<AppUser?> restore() async => user;
}

class _RecordingApi extends Fake implements ApiClient {
  final paths = <String>[];
  final bodies = <Object?>[];

  @override
  Future<Object?> put(String path, Object? body) async {
    paths.add(path);
    bodies.add(body);
    return 1;
  }
}
