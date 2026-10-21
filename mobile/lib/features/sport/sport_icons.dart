import 'package:flutter/material.dart';

import 'sport.dart';

const _iconsByKeyword = <String, IconData>{
  'american football': Icons.sports_football,
  'football': Icons.sports_football,
  'nfl': Icons.sports_football,
  'fussball': Icons.sports_soccer,
  'eishockey': Icons.sports_hockey,
  'unihockey': Icons.sports_hockey,
  'hockey': Icons.sports_hockey,
  'basketball': Icons.sports_basketball,
  'volleyball': Icons.sports_volleyball,
  'handball': Icons.sports_handball,
  'tennis': Icons.sports_tennis,
  'e-sport': Icons.sports_esports,
  'esport': Icons.sports_esports,
  'motorsport': Icons.sports_motorsports,
  'formel': Icons.sports_motorsports,
  'rad': Icons.directions_bike,
  'langlauf': Icons.nordic_walking,
  'ski': Icons.downhill_skiing,
  'snowboard': Icons.snowboarding,
  'schwingen': Icons.sports_kabaddi,
  'golf': Icons.sports_golf,
  'rugby': Icons.sports_rugby,
  'baseball': Icons.sports_baseball,
  'cricket': Icons.sports_cricket,
  'leichtathletik': Icons.directions_run,
  'schwimmen': Icons.pool,
  'rudern': Icons.rowing,
  'segeln': Icons.sailing,
  'boxen': Icons.sports_mma,
  'turnen': Icons.sports_gymnastics,
  'eiskunstlauf': Icons.ice_skating,
};

/// Icon for a root sport by its German label; organisations get a building, unknown sports a trophy.
IconData sportIcon(Sport sport) {
  if (sport.isOrganisation) return Icons.apartment;
  final label = sport.label.toLowerCase();
  for (final MapEntry(:key, :value) in _iconsByKeyword.entries) {
    if (label.contains(key)) return value;
  }
  return Icons.emoji_events_outlined;
}
