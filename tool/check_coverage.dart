// Enforces line-coverage floors against coverage/lcov.info.
//
//   flutter test --coverage --exclude-tags golden
//   dart run tool/check_coverage.dart
//
// Two floors on purpose: a single global number can sit at 85 % while the
// domain — where a wrong answer is silent — sits far lower, because widget
// tests inflate the average.
import 'dart:io';

const double overallFloor = 80;

/// Path prefix -> floor. A rule that matches no file fails the run: it almost
/// always means a directory moved and the rule silently stopped protecting it.
const Map<String, double> pathFloors = <String, double>{
  'lib/features/home/domain/': 95,
  'lib/core/': 90,
};

/// Generated or entry-point code: counting it measures the generator.
bool isExcluded(String path) =>
    path.endsWith('.g.dart') ||
    path.endsWith('.freezed.dart') ||
    path.contains('/generated/') ||
    path.startsWith('lib/app/l10n/app_localizations') ||
    path == 'lib/main.dart' ||
    path == 'lib/app/bootstrap/bootstrap.dart';

void main() {
  final File lcov = File('coverage/lcov.info');
  if (!lcov.existsSync()) {
    stderr.writeln(
      'check_coverage: coverage/lcov.info missing — run flutter test --coverage first.',
    );
    exit(1);
  }

  final Map<String, (int, int)> files = <String, (int, int)>{};
  String? current;
  int found = 0;
  int hit = 0;
  for (final String line in lcov.readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      current = line.substring(3).replaceAll(r'\', '/');
      found = 0;
      hit = 0;
    } else if (line.startsWith('DA:')) {
      found++;
      if (!line.endsWith(',0')) hit++;
    } else if (line == 'end_of_record' && current != null) {
      files[current] = (found, hit);
      current = null;
    }
  }

  final Map<String, (int, int)> counted = <String, (int, int)>{
    for (final MapEntry<String, (int, int)> e in files.entries)
      if (!isExcluded(e.key)) e.key: e.value,
  };
  if (counted.isEmpty) {
    stderr.writeln('check_coverage: no countable files in lcov.info.');
    exit(1);
  }

  bool failed = false;
  void report(String label, Iterable<(int, int)> values, double floor) {
    final int total = values.fold(0, (int sum, (int, int) v) => sum + v.$1);
    final int covered = values.fold(0, (int sum, (int, int) v) => sum + v.$2);
    final double pct = total == 0 ? 100 : covered * 100 / total;
    final bool ok = pct >= floor;
    failed |= !ok;
    stdout.writeln(
      '${ok ? '✓' : '✗'} ${label.padRight(34)} ${pct.toStringAsFixed(1).padLeft(5)}%  '
      '($covered/$total, floor $floor%)',
    );
  }

  report('overall', counted.values, overallFloor);
  for (final MapEntry<String, double> rule in pathFloors.entries) {
    final Iterable<(int, int)> matched = counted.entries
        .where((MapEntry<String, (int, int)> e) => e.key.startsWith(rule.key))
        .map((MapEntry<String, (int, int)> e) => e.value);
    if (matched.isEmpty) {
      stdout.writeln('✗ ${rule.key.padRight(34)} matched NO files');
      failed = true;
      continue;
    }
    report(rule.key, matched, rule.value);
  }

  final List<String> worst =
      (counted.entries.toList()..sort(
            (MapEntry<String, (int, int)> a, MapEntry<String, (int, int)> b) =>
                (a.value.$2 / a.value.$1).compareTo(b.value.$2 / b.value.$1),
          ))
          .take(5)
          .map(
            (MapEntry<String, (int, int)> e) =>
                '  ${e.key}: ${e.value.$2}/${e.value.$1}',
          )
          .toList();
  stdout.writeln('\nLeast covered:\n${worst.join('\n')}');
  exit(failed ? 1 : 0);
}
