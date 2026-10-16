import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';

/// This period's usage as a bar, never as credits (D9). Orange once used up.
class UsageBar extends StatelessWidget {
  const UsageBar({required this.percent, this.out = false, super.key});

  final int percent;
  final bool out;

  @override
  Widget build(BuildContext context) {
    final double fraction = (out ? 100 : percent.clamp(0, 100)) / 100;
    return Semantics(
      value: '$percent%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AlesleRadii.capsule),
        child: SizedBox(
          height: 8,
          child: Stack(
            children: <Widget>[
              const Positioned.fill(
                child: ColoredBox(color: AlesleColors.hairline),
              ),
              FractionallySizedBox(
                widthFactor: fraction,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: out
                        ? AlesleColors.notDoneGradient
                        : AlesleColors.violetGradient,
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
