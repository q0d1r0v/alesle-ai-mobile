import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum CapsuleStyle {
  /// Ink fill, white text: the one main action.
  primary,

  /// Light grey: the alternative (Cancel, Undo).
  secondary,

  /// White with a hairline: an option on a tinted background.
  outlined,

  /// Text only: "Not now".
  text,
}

/// The design system's capsule button ("BUTTONS · CAPSULE").
class CapsuleButton extends StatelessWidget {
  const CapsuleButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.style = CapsuleStyle.primary,
    this.icon,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final CapsuleStyle style;
  final IconData? icon;

  /// Text colour override, e.g. red for a destructive text button.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final (
      Color background,
      Color foreground,
      BorderSide side,
    ) = switch (style) {
      CapsuleStyle.primary => (AlesleColors.ink, Colors.white, BorderSide.none),
      CapsuleStyle.secondary => (
        AlesleColors.capsuleGrey,
        AlesleColors.ink,
        BorderSide.none,
      ),
      CapsuleStyle.outlined => (
        Colors.white,
        AlesleColors.ink,
        const BorderSide(color: AlesleColors.hairline),
      ),
      CapsuleStyle.text => (
        Colors.transparent,
        AlesleColors.text2,
        BorderSide.none,
      ),
    };
    final Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (icon case final IconData value) ...<Widget>[
          Icon(value, size: 18),
          const SizedBox(width: 8),
        ],
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
    final Widget button = TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: background,
        foregroundColor: color ?? foreground,
        disabledBackgroundColor: background.withValues(alpha: 0.4),
        minimumSize: Size(64, style == CapsuleStyle.text ? 44 : 56),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: StadiumBorder(side: side),
        textStyle: Theme.of(context).textTheme.labelLarge,
      ),
      child: child,
    );
    if (style != CapsuleStyle.primary || onPressed == null) return button;
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(AlesleRadii.capsule)),
        boxShadow: AlesleShadows.capsule,
      ),
      child: button,
    );
  }
}
