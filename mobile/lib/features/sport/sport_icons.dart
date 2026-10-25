import 'package:flutter/material.dart';

import '../../theme.dart';
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

/// [sport]'s icon in a circle; flies from the start tile into the title of the page it opens.
class SportAvatar extends StatelessWidget {
  const SportAvatar({super.key, required this.sport, this.size = 40, this.color = Colors.white});

  final Sport sport;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: Hero(
      tag: 'sport-icon-${sport.id}',
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        // Scales with the flight between the two sizes
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Icon(sportIcon(sport), color: Theme.of(context).colorScheme.primary, size: 22),
          ),
        ),
      ),
    ),
  );
}

/// AppBar title with the [sport]'s avatar in front, the landing place of the start tile's icon.
class SportTitle extends StatelessWidget {
  const SportTitle({super.key, required this.sport});

  final Sport sport;

  @override
  Widget build(BuildContext context) => Row(
    spacing: 12,
    children: [
      SportAvatar(sport: sport, size: 34, color: SynciColors.container),
      Flexible(child: Text(sport.label, overflow: TextOverflow.ellipsis)),
    ],
  );
}
