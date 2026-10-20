import 'package:flutter/material.dart';

import 'sport.dart';

/// Round team logo; teams without logo, or whose logo fails to load, show the generic team icon.
class TeamLogo extends StatelessWidget {
  const TeamLogo({super.key, required this.team, this.size = 36});

  final Team team;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = SizedBox.square(dimension: size, child: const Icon(Icons.groups_outlined));
    final url = team.logoUrl;
    if (url == null || url.isEmpty) return fallback;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Image.network(
        url,
        fit: BoxFit.contain,
        semanticLabel: team.name,
        errorBuilder: (_, _, _) => const Icon(Icons.groups_outlined),
      ),
    );
  }
}
