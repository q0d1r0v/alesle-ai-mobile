import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A white rounded card; its own [Material] so list tiles inside show ink.
class AlesleCard extends StatelessWidget {
  const AlesleCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AlesleRadii.card);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AlesleShadows.card,
      ),
      child: Material(
        color: Colors.white,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}

/// Rows in one card, divided by hairlines (iOS-style grouped list).
class AlesleGroup extends StatelessWidget {
  const AlesleGroup({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AlesleCard(
      child: Column(
        children: <Widget>[
          for (final (int index, Widget child) in children.indexed) ...<Widget>[
            if (index > 0)
              const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: AlesleColors.hairline,
              ),
            child,
          ],
        ],
      ),
    );
  }
}
