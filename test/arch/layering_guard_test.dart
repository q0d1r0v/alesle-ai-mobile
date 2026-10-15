@Tags(<String>['arch'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Architecture rules, enforced by reading the source. The analyzer has no
/// concept of a layer; these fail the commit that breaks one.
void main() {
  final Directory lib = Directory('lib');

  setUpAll(() {
    // Guard the guard: a rule that scans nothing passes forever.
    expect(
      lib.existsSync(),
      isTrue,
      reason: 'Run tests from the package root.',
    );
    expect(
      _featureDirs(),
      isNotEmpty,
      reason: 'No features found under lib/features.',
    );
  });

  test('domain layers are pure Dart', () {
    const List<String> forbidden = <String>[
      'package:flutter/',
      'package:flutter_riverpod/',
      'package:dio/',
      'package:go_router/',
      'package:retrofit/',
      '/core/api/',
      '/core/platform/',
      '/data/',
      '/presentation/',
    ];
    final List<String> violations = <String>[
      for (final Directory feature in _featureDirs())
        for (final File file in _dartFiles('${feature.path}/domain'))
          for (final String line in _imports(file))
            if (forbidden.any(line.contains)) '${file.path}: $line',
    ];
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('features do not import each other', () {
    final List<String> violations = <String>[];
    for (final Directory feature in _featureDirs()) {
      final String name = feature.uri.pathSegments
          .where((s) => s.isNotEmpty)
          .last;
      for (final File file in _dartFiles(feature.path)) {
        for (final String line in _imports(file)) {
          final RegExpMatch? match = RegExp(r'features/([a-z_]+)/')
              .firstMatch(line);
          if (match != null && match.group(1) != name) {
            violations.add('${file.path}: $line');
          }
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('generated transport code is only used by data and core layers', () {
    const List<String> generated = <String>[
      '/core/api/generated/',
      '/core/platform/generated/',
    ];
    final List<String> violations = <String>[
      for (final File file in _dartFiles('lib'))
        if (!file.path.contains('/data/') &&
            !file.path.startsWith('lib/core/') &&
            !file.path.endsWith('failure_message.dart'))
          for (final String line in _imports(file))
            if (generated.any(line.contains) &&
                !line.contains('models/error_code.dart'))
              '${file.path}: $line',
    ];
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('nothing reads process-level environment at runtime', () {
    final List<String> violations = <String>[
      for (final File file in _dartFiles('lib'))
        if (file.readAsStringSync().contains('Platform.environment')) file.path,
    ];
    expect(
      violations,
      isEmpty,
      reason: 'Use AppConfig (dart-define) instead:\n${violations.join('\n')}',
    );
  });
}

List<Directory> _featureDirs() {
  final Directory features = Directory('lib/features');
  if (!features.existsSync()) return <Directory>[];
  return features.listSync().whereType<Directory>().toList();
}

Iterable<File> _dartFiles(String path) {
  final FileSystemEntity entity = FileSystemEntity.isDirectorySync(path)
      ? Directory(path)
      : File(path);
  if (entity is File) return entity.existsSync() ? <File>[entity] : <File>[];
  final Directory dir = entity as Directory;
  if (!dir.existsSync()) return <File>[];
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where(
        (File f) => f.path.endsWith('.dart') && !f.path.contains('/generated/'),
      );
}

Iterable<String> _imports(File file) =>
    file.readAsLinesSync().where((String line) => line.startsWith('import '));
