import 'dart:convert';
import 'dart:io';

void main() {
  final root = Directory.current;
  final registry = Directory('${root.path}/registry');
  if (!registry.existsSync()) {
    _fail('Missing registry directory.');
  }

  final manifestFile = File('${registry.path}/components.json');
  final schemaFile = File('${registry.path}/components.schema.json');
  final sharedManifestFile = File(
    '${registry.path}/shared/shared_manifest.json',
  );
  final availableComponentsFile = File(
    '${registry.path}/available_components.txt',
  );

  final manifest = _readJsonObject(manifestFile);
  _readJsonObject(schemaFile);
  if (sharedManifestFile.existsSync()) {
    _readJsonObject(sharedManifestFile);
  }

  final components = manifest['components'];
  if (components is! List || components.isEmpty) {
    _fail(
      'registry/components.json must contain a non-empty components array.',
    );
  }

  final ids = <String>{};
  final sources = <String>{};
  for (final item in components) {
    if (item is! Map) {
      _fail('Every component entry must be a JSON object.');
    }
    final id = item['id'];
    if (id is! String || id.trim().isEmpty) {
      _fail('Every component entry must have a non-empty string id.');
    }
    if (!ids.add(id)) {
      _fail('Duplicate component id: $id');
    }

    final files = item['files'];
    if (files is! List || files.isEmpty) {
      _fail('Component "$id" must declare at least one file.');
    }
    for (final fileEntry in files) {
      if (fileEntry is! Map) {
        _fail('Component "$id" has a non-object file entry.');
      }
      final source = fileEntry['source'];
      if (source is! String || source.trim().isEmpty) {
        _fail('Component "$id" has a file entry without a source.');
      }
      if (source.contains('..') || source.startsWith('/')) {
        _fail('Component "$id" has unsafe source path: $source');
      }
      if (!sources.add('$id:$source')) {
        _fail('Component "$id" declares duplicate source: $source');
      }
      final sourcePath = source.startsWith('registry/')
          ? '${root.path}/$source'
          : '${registry.path}/$source';
      if (!File(sourcePath).existsSync()) {
        _fail('Component "$id" references missing source: $source');
      }
    }
  }

  if (availableComponentsFile.existsSync()) {
    final available = availableComponentsFile
        .readAsLinesSync()
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('#'))
        .toSet();
    final availableIds = available
        .where((line) => line.contains('/'))
        .map((line) => line.split('/').last)
        .toSet();
    final missing = ids.difference(availableIds);
    if (missing.isNotEmpty) {
      _fail(
        'available_components.txt is missing component ids: '
        '${missing.take(10).join(', ')}',
      );
    }
  }

  stdout.writeln('Registry verification summary:');
  stdout.writeln('  Components: ${ids.length}');
  stdout.writeln('  File entries: ${sources.length}');
  stdout.writeln('  Status: OK');
}

Map<String, dynamic> _readJsonObject(File file) {
  if (!file.existsSync()) {
    _fail('Missing required JSON file: ${file.path}');
  }
  try {
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
    _fail('JSON file must contain an object: ${file.path}');
  } on FormatException catch (error) {
    _fail('Invalid JSON in ${file.path}: ${error.message}');
  }
}

Never _fail(String message) {
  stderr.writeln(message);
  exitCode = 1;
  throw StateError(message);
}
