import 'package:flutter/material.dart';

import 'sport.dart';

/// "Chicago Bears" -> "CB", "Zug" -> "ZU", as on the website.
String teamInitials(String name) {
  final words = name.split(RegExp(r'\s+')).where((w) => w.contains(RegExp(r'\p{L}', unicode: true))).toList();
  if (words.length >= 2) return (words.first[0] + words.last[0]).toUpperCase();
  final letters = name.replaceAll(RegExp(r'[^\p{L}\p{N}]', unicode: true), '');
  return letters.substring(0, letters.length.clamp(0, 2)).toUpperCase();
}

/// Round team logo; teams without logo, or whose logo fails to load, show their initials.
class TeamLogo extends StatelessWidget {
  const TeamLogo({super.key, required this.team, this.size = 36});

  /// The size the website's logo srcset is made for.
  static const _srcSetSize = 36.0;

  final Team team;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = team.logoFor(MediaQuery.devicePixelRatioOf(context) * size / _srcSetSize);
    final initials = _Initials(name: team.name, size: size);
    return Container(
      width: size,
      height: size,
      // Logos are rarely square: show them whole with a little air
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: url == null || url.isEmpty
          ? initials
          : Image.network(
              url,
              fit: BoxFit.contain,
              // The team name is always shown next to it
              excludeFromSemantics: true,
              frameBuilder: (_, child, frame, synchronous) => synchronous
                  ? child
                  : AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: child,
                    ),
              errorBuilder: (_, _, _) => initials,
            ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.name, required this.size});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          teamInitials(name),
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: size * 0.32,
          ),
        ),
      ),
    ),
  );
}
