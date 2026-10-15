import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The orb of the design system: what Alesle is doing, at a glance.
enum OrbState {
  /// "Tap to speak": the ring and the violet core.
  idle,

  /// Listening: the same, with a soft halo.
  listening,

  /// Working: a grey ring with a turning violet arc.
  working,

  /// Done: green with a check.
  done,

  /// Not done: orange with an exclamation mark.
  notDone,
}

class AlesleOrb extends StatefulWidget {
  const AlesleOrb({super.key, this.state = OrbState.idle, this.size = 200});

  final OrbState state;
  final double size;

  @override
  State<AlesleOrb> createState() => _AlesleOrbState();
}

class _AlesleOrbState extends State<AlesleOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    _syncSpin();
  }

  @override
  void didUpdateWidget(AlesleOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSpin();
  }

  void _syncSpin() {
    if (widget.state == OrbState.working) {
      if (!_spin.isAnimating) _spin.repeat();
    } else {
      _spin.stop();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size;
    return SizedBox.square(
      dimension: size,
      child: switch (widget.state) {
        OrbState.done => _Badge(
          size: size,
          gradient: AlesleColors.doneGradient,
          glow: const Color(0x521E8F4E),
          icon: Icons.check_rounded,
        ),
        OrbState.notDone => _Badge(
          size: size,
          gradient: AlesleColors.notDoneGradient,
          glow: const Color(0x52D9730F),
          icon: Icons.priority_high_rounded,
        ),
        _ => DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: <BoxShadow>[
              if (widget.state == OrbState.listening)
                BoxShadow(
                  color: AlesleColors.violetGlow.withValues(alpha: 0.18),
                  spreadRadius: size * 0.08,
                ),
              BoxShadow(
                color: AlesleColors.violet.withValues(alpha: 0.30),
                blurRadius: size * 0.25,
                offset: Offset(0, size * 0.1),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _spin,
            builder: (BuildContext context, Widget? child) => CustomPaint(
              painter: _OrbPainter(
                working: widget.state == OrbState.working,
                turn: _spin.value,
                listening: widget.state == OrbState.listening,
              ),
            ),
          ),
        ),
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.size,
    required this.gradient,
    required this.glow,
    required this.icon,
  });

  final double size;
  final Gradient gradient;
  final Color glow;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: glow,
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.45),
    );
  }
}

/// The ink "C" around a violet sphere; while working, a grey ring with a turning arc.
class _OrbPainter extends CustomPainter {
  _OrbPainter({
    required this.working,
    required this.turn,
    required this.listening,
  });

  final bool working;
  final double turn;
  final bool listening;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.width / 2;
    final double stroke = radius * (working ? 0.1 : 0.16);
    final Rect ring = Rect.fromCircle(
      center: center,
      radius: radius * 0.66 - stroke / 2,
    );

    if (working) {
      canvas
        ..drawArc(
          ring,
          0,
          math.pi * 2,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke
            ..color = AlesleColors.hairline,
        )
        ..drawArc(
          ring,
          turn * math.pi * 2 - math.pi / 2,
          math.pi * 0.6,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke
            ..strokeCap = StrokeCap.round
            ..color = AlesleColors.violet,
        );
    } else {
      // The "C": a ring open on the right.
      canvas.drawArc(
        ring,
        math.pi * 0.22,
        math.pi * 1.56,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.butt
          ..color = AlesleColors.ink,
      );
    }

    final double core = radius * (working ? 0.18 : (listening ? 0.30 : 0.26));
    canvas.drawCircle(
      center,
      core,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: <Color>[AlesleColors.violetLight, AlesleColors.violet],
        ).createShader(Rect.fromCircle(center: center, radius: core)),
    );
  }

  @override
  bool shouldRepaint(_OrbPainter old) =>
      old.working != working || old.turn != turn || old.listening != listening;
}
