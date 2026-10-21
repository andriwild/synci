import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/widgets/synci_logo.dart';
import '../organisation/organisation_providers.dart';
import '../sport/sport_providers.dart';

/// Size of the symbol in the native splash (assets/icon/splash.png: 571 of 768 px at 4x), so the handover is seamless.
const splashLogoSize = 142.8;

/// Takes over from the native splash: the sync arrows turn until the start data is loaded, then the splash fades out.
class SplashGate extends ConsumerStatefulWidget {
  const SplashGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends ConsumerState<SplashGate> with TickerProviderStateMixin {
  static const _maxWait = Duration(seconds: 4);

  late final _turn = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
  late final _fade = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
  late final _turns = CurvedAnimation(parent: _turn, curve: Curves.easeInOutCubic);
  var _loaded = false;
  var _started = false;
  var _showApp = false;
  var _done = false;

  @override
  void initState() {
    super.initState();
    // Stops only after a full turn, with the arrows back in place
    _turn.addStatusListener((status) {
      if (status != AnimationStatus.completed) return;
      _loaded ? _finish() : _turn.forward(from: 0);
    });
    unawaited(_load());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (!MediaQuery.disableAnimationsOf(context)) _turn.forward();
  }

  @override
  void dispose() {
    _turns.dispose();
    _turn.dispose();
    _fade.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      await Future.wait([
        ref.read(authControllerProvider.future),
        ref.read(sportsProvider.future),
        ref.read(myOrganisationsProvider.future),
      ]).timeout(_maxWait);
    } on Object {
      // The screens show errors themselves
    }
    if (!mounted) return;
    _loaded = true;
    if (!_turn.isAnimating) _finish();
  }

  void _finish() {
    if (_showApp) return;
    setState(() => _showApp = true);
    _fade.forward().then((_) {
      if (mounted) setState(() => _done = true);
    });
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      if (_showApp) widget.child,
      if (!_done)
        FadeTransition(
          opacity: ReverseAnimation(_fade),
          child: ColoredBox(
            color: Colors.white,
            child: Center(
              child: SynciLogo(size: splashLogoSize, syncTurns: _turns),
            ),
          ),
        ),
    ],
  );
}
