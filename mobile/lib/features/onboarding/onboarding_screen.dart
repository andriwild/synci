import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'onboarding_illustrations.dart';
import 'onboarding_providers.dart';

class _Story {
  const _Story({
    required this.title,
    required this.text,
    required this.background,
    required this.illustration,
    this.duration = const Duration(seconds: 7),
  });

  final String title;
  final String text;
  final Color background;
  final Widget illustration;
  final Duration duration;
}

const _stories = [
  _Story(
    title: 'Willkommen bei Synci',
    text: 'Verpasse nie wieder deine Lieblingsevents. Synci bringt Spiele, Rennen und Turniere direkt in deinen Kalender.',
    background: Color(0xFFEBF0F6),
    illustration: WelcomeIllustration(),
    duration: Duration(seconds: 5),
  ),
  _Story(
    title: 'Wähle, was dich interessiert',
    text:
        'Von der Super League über die NHL bis zur Formel 1: Nimm eine ganze Sportart, eine Liga, nur dein Team '
        'oder einzelne Events.',
    background: Color(0xFFFFF9CF),
    illustration: SportsIllustration(),
  ),
  _Story(
    title: 'Sammle alles in einem Abo',
    text:
        'Deine Auswahl landet in einem Abo. Du kannst auch mehrere anlegen, z.B. eines für dich und eines für die '
        'Familie. Dafür brauchst du nur ein kostenloses Konto.',
    background: Color(0xFFE5F0F5),
    illustration: AboIllustration(),
  ),
  _Story(
    title: 'Einmal abonnieren, immer aktuell',
    text:
        'Füge dein Abo deinem Kalender hinzu, egal ob Apple, Google oder Outlook. Neue Spiele und Verschiebungen '
        'kommen automatisch dazu.',
    background: Color(0xFFEBF0F6),
    illustration: CalendarIllustration(),
  ),
  _Story(
    title: 'Auch für deinen Verein',
    text:
        'Vereine und Gruppen teilen auf Synci ihre eigenen Termine wie Trainings oder Anlässe. Tritt bei und '
        'abonniere sie wie jede Sportart.',
    background: Color(0xFFFFF9CF),
    illustration: OrganisationIllustration(),
  ),
];

/// Intro as a story: it advances by itself, a tap on the left or right goes back or forward, holding pauses.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> with SingleTickerProviderStateMixin {
  late final _progress = AnimationController(vsync: this)..addStatusListener(_onProgress);
  var _index = 0;
  var _started = false;

  /// Screen reader users go on with the buttons only.
  var _autoplay = true;

  bool get _isLast => _index == _stories.length - 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _autoplay = !MediaQuery.accessibleNavigationOf(context);
    if (_started) return;
    _started = true;
    _play();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _onProgress(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_isLast) _show(_index + 1);
  }

  void _show(int index) {
    setState(() => _index = index);
    _play();
  }

  void _play() {
    _progress.duration = _stories[_index].duration;
    _progress.value = 0;
    if (_autoplay) _progress.forward();
  }

  void _next() => _isLast ? _finish() : _show(_index + 1);

  void _previous() => _show(_index > 0 ? _index - 1 : 0);

  void _pause() => _progress.stop();

  void _resume() {
    if (_autoplay && !_progress.isCompleted) _progress.forward();
  }

  void _finish() {
    _progress.stop();
    ref.read(onboardingSeenProvider.notifier).markSeen();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/sport');
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = _stories[_index];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          color: story.background,
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 4, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ProgressBars(count: _stories.length, index: _index, progress: _progress),
                      ),
                      Visibility.maintain(
                        visible: !_isLast,
                        child: TextButton(onPressed: _finish, child: const Text('Überspringen')),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      // The buttons below do the same for screen readers
                      excludeFromSemantics: true,
                      onTapUp: (details) => details.localPosition.dx < constraints.maxWidth / 3 ? _previous() : _next(),
                      onLongPressStart: (_) => _pause(),
                      onLongPressEnd: (_) => _resume(),
                      onHorizontalDragEnd: (details) {
                        final velocity = details.primaryVelocity ?? 0;
                        if (velocity < -300) _next();
                        if (velocity > 300) _previous();
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: animation.drive(Tween(begin: const Offset(0.04, 0), end: Offset.zero)),
                            child: child,
                          ),
                        ),
                        child: _StoryPage(key: ValueKey(_index), story: story),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Row(
                    spacing: 12,
                    children: [
                      if (_index > 0)
                        IconButton.outlined(
                          tooltip: 'Zurück',
                          onPressed: _previous,
                          icon: const Icon(Icons.arrow_back),
                        ),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                          onPressed: _next,
                          child: Text(_isLast ? "Los geht's" : 'Weiter'),
                        ),
                      ),
                    ],
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

class _ProgressBars extends StatelessWidget {
  const _ProgressBars({required this.count, required this.index, required this.progress});

  final int count;
  final int index;
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Semantics(
      label: 'Schritt ${index + 1} von $count',
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: progress,
          builder: (context, _) => Row(
            spacing: 4,
            children: [
              for (var i = 0; i < count; i++)
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: i < index ? 1 : (i == index ? progress.value : 0),
                      minHeight: 3,
                      color: color,
                      backgroundColor: color.withValues(alpha: 0.18),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoryPage extends StatelessWidget {
  const _StoryPage({super.key, required this.story});

  final _Story story;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(width: illustrationWidth, child: story.illustration),
              ),
            ),
          ),
          Flexible(
            flex: 3,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      story.title,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(story.text, style: theme.textTheme.bodyLarge?.copyWith(height: 1.4)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
