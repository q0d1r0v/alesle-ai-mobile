import 'dart:math' as math;

import '../../../app/l10n/app_localizations.dart';

/// Everyday commands shown in the live conversation, so a new user knows
/// what to say. General on purpose: nothing about a particular person.
List<String> liveExamples(AppLocalizations l10n) => <String>[
  l10n.liveExample1,
  l10n.liveExample2,
  l10n.liveExample3,
  l10n.liveExample4,
  l10n.liveExample5,
  l10n.liveExample6,
  l10n.liveExample7,
  l10n.liveExample8,
];

/// [count] different examples from [all]; another [seed] (each opening)
/// shows another set.
List<String> pickExamples(List<String> all, int seed, {int count = 3}) {
  if (all.isEmpty) return const <String>[];
  final int start = seed.abs() % all.length;
  return <String>[
    for (int i = 0; i < math.min(count, all.length); i++)
      all[(start + i) % all.length],
  ];
}
