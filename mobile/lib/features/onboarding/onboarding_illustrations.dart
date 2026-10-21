import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/widgets/synci_logo.dart';
import '../sport/sport.dart';
import '../sport/sport_icons.dart';
import '../sport/team_logo.dart';

/// Illustrations are laid out this wide, at their natural height, and scaled down as a whole when they do not fit.
const illustrationWidth = 320.0;

/// Plays an entrance animation once, unless the system reduces motion.
class _Entrance extends StatefulWidget {
  const _Entrance({required this.duration, required this.builder});

  final Duration duration;
  final Widget Function(BuildContext context, Animation<double> animation) builder;

  @override
  State<_Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<_Entrance> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: widget.duration);
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controller);
}

/// Fades and slides [child] in during the part of [animation] that starts at [start].
Widget _appear(Animation<double> animation, double start, Widget child, {Offset from = const Offset(0, 0.3)}) {
  final progress = animation.drive(
    CurveTween(curve: Interval(start, math.min(start + 0.4, 1), curve: Curves.easeOutCubic)),
  );
  return FadeTransition(
    opacity: progress,
    child: SlideTransition(
      position: progress.drive(Tween(begin: from, end: Offset.zero)),
      child: child,
    ),
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: 300,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 8))],
    ),
    child: child,
  );
}

class _IconBadge extends StatelessWidget {
  const _IconBadge(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainer, shape: BoxShape.circle),
    child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
  );
}

class _Row extends StatelessWidget {
  const _Row({required this.leading, required this.title, required this.subtitle, this.trailing});

  final Widget leading;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        spacing: 12,
        children: [
          leading,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600), maxLines: 1),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                  maxLines: 1,
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// The logo with its sync arrows turning every few seconds.
class WelcomeIllustration extends StatefulWidget {
  const WelcomeIllustration({super.key});

  @override
  State<WelcomeIllustration> createState() => _WelcomeIllustrationState();
}

class _WelcomeIllustrationState extends State<WelcomeIllustration> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
  late final _turns = _controller.drive(CurveTween(curve: const Interval(0.25, 0.75, curve: Curves.easeInOutCubic)));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!MediaQuery.disableAnimationsOf(context) && !_controller.isAnimating) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 32, offset: const Offset(0, 12)),
        ],
      ),
      alignment: Alignment.center,
      child: SynciLogo(size: 140, syncTurns: _turns),
    ),
  );
}

/// Sports popping up one after the other.
class SportsIllustration extends StatelessWidget {
  const SportsIllustration({super.key});

  static const _sports = [
    'Fussball',
    'Eishockey',
    'Tennis',
    'Ski Alpin',
    'Basketball',
    'Motorsport',
    'Unihockey',
    'E-Sport',
    'American Football',
    'Handball',
    'Volleyball',
    'Schwingen',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Entrance(
      duration: const Duration(milliseconds: 1600),
      builder: (context, animation) => Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 10,
          children: [
            for (final (index, label) in _sports.indexed)
              ScaleTransition(
                scale: animation.drive(
                  CurveTween(curve: Interval(index * 0.05, index * 0.05 + 0.4, curve: Curves.easeOutBack)),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 6,
                    children: [
                      Icon(
                        sportIcon(Sport(id: label, label: label)),
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      Text(label, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// An abo filling up with a team, a league and a racing series.
class AboIllustration extends StatelessWidget {
  const AboIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final check = Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 22);
    final rows = [
      _Row(
        leading: const TeamLogo(
          team: Team(id: 'zsc', sourceId: 0, name: 'ZSC Lions'),
        ),
        title: 'ZSC Lions',
        subtitle: 'Eishockey · Team',
        trailing: check,
      ),
      _Row(
        leading: const _IconBadge(Icons.sports_soccer),
        title: 'Super League',
        subtitle: 'Fussball · Liga',
        trailing: check,
      ),
      _Row(
        leading: const _IconBadge(Icons.sports_motorsports),
        title: 'Formel 1',
        subtitle: 'Motorsport · Rennserie',
        trailing: check,
      ),
    ];
    return _Entrance(
      duration: const Duration(milliseconds: 1600),
      builder: (context, animation) => Center(
        child: _appear(
          animation,
          0,
          _Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Icon(Icons.event_note, color: theme.colorScheme.primary),
                    Text('Mein Abo', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const Divider(height: 24),
                for (final (index, row) in rows.indexed)
                  _appear(animation, 0.2 + index * 0.2, row, from: const Offset(0.3, 0)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Events arriving in the calendar, then the sync arrows turn once.
class CalendarIllustration extends StatelessWidget {
  const CalendarIllustration({super.key});

  static const _events = [
    (day: 'Sa', time: '19:45', title: 'ZSC Lions – HC Davos', color: Color(0xFF3D5A80)),
    (day: 'So', time: '16:30', title: 'FC Basel – FC Zürich', color: Color(0xFF98C1D9)),
    (day: 'So', time: '21:00', title: 'Formel 1 · Grosser Preis', color: Color(0xFFE9C46A)),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Entrance(
      duration: const Duration(milliseconds: 2400),
      builder: (context, animation) => Center(
        child: _appear(
          animation,
          0,
          _Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_month, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dein Kalender',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    SynciLogo(
                      size: 28,
                      syncTurns: animation.drive(
                        CurveTween(curve: const Interval(0.6, 1, curve: Curves.easeInOutCubic)),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                for (final (index, event) in _events.indexed)
                  _appear(
                    animation,
                    0.1 + index * 0.15,
                    from: const Offset(0.3, 0),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 44,
                            child: Column(
                              children: [
                                Text(event.day, style: theme.textTheme.labelMedium),
                                Text(
                                  event.time,
                                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                color: event.color.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(8),
                                border: Border(left: BorderSide(color: event.color, width: 4)),
                              ),
                              child: Text(
                                event.title,
                                style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A club with its groups and own dates.
class OrganisationIllustration extends StatelessWidget {
  const OrganisationIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = [
      const _Row(leading: _IconBadge(Icons.fitness_center), title: 'Training', subtitle: 'Di 19:00 · 1. Mannschaft'),
      const _Row(
        leading: _IconBadge(Icons.sports_soccer),
        title: 'FC Seeblick – FC Talwil',
        subtitle: 'Sa 16:00 · Sportplatz',
      ),
      const _Row(
        leading: _IconBadge(Icons.celebration_outlined),
        title: 'Vereinsfest',
        subtitle: 'So · ganztägig · Clubhaus',
      ),
    ];
    return _Entrance(
      duration: const Duration(milliseconds: 1800),
      builder: (context, animation) => Center(
        child: _appear(
          animation,
          0,
          _Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  spacing: 12,
                  children: [
                    const _IconBadge(Icons.apartment),
                    Expanded(
                      child: Text(
                        'FC Seeblick',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  children: [
                    for (final group in ['1. Mannschaft', 'Junioren'])
                      Chip(label: Text(group), visualDensity: VisualDensity.compact),
                  ],
                ),
                const Divider(height: 20),
                for (final (index, row) in rows.indexed)
                  _appear(animation, 0.2 + index * 0.18, row, from: const Offset(0.3, 0)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
