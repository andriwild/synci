/// Whether [candidate] is a later version than [installed], comparing the dotted numbers one by one
/// ("1.10.0" is later than "1.9.2").
bool isLaterVersion(String candidate, String installed) {
  final a = _parts(candidate);
  final b = _parts(installed);
  for (var i = 0; i < a.length || i < b.length; i++) {
    final x = i < a.length ? a[i] : 0;
    final y = i < b.length ? b[i] : 0;
    if (x != y) return x > y;
  }
  return false;
}

List<int> _parts(String version) => [for (final part in version.split('.')) int.tryParse(part) ?? 0];
