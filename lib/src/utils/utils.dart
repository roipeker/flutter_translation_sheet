import 'dart:convert';
import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:flutter_translation_sheet/flutter_translation_sheet.dart';
import 'package:path/path.dart' as p;
import 'package:watcher/watcher.dart';

import '../runner.dart';

export 'json2yaml.dart';
export 'logger.dart';
export 'version.dart';
export 'errors.dart';

/// Encodes a json into a tabular format for easy redeability.
String prettyJson(dynamic json) {
  return JsonEncoder.withIndent('  ' * 2).convert(json);
}

/// Save the [content] in [path] file, creating the [path] if doesn't exists.
void saveString(String path, String content) {
  var f = File(path);
  if (!f.existsSync()) {
    f.createSync(recursive: true);
  }
  var point = f.openSync(mode: FileMode.write);
  point.writeStringSync(content);
  point.closeSync();
}

/// Reads the contents of the [path] file as String.
/// If files doesn't exists, returns empty String.
String openString(String path) {
  // if (useDataDir && !path.startsWith('data/')) {
  //   path = 'data/master/$path';
  // }
  var f = File(path);
  if (f.existsSync()) return f.readAsStringSync();
  print('openString(): ${f.uri} does not exists.');
  return '';
}

/// Shortcut utility to join paths properly in different environments.
/// Alias of [buildPath]
String joinDir(List<String> paths) {
  return buildPath(paths);
}

/// Shortcut utility to join paths properly in different environments.
String buildPath(List<String> path) {
  return p.canonicalize(p.joinAll(path));
}

/// Moves a file in the system in async way.
Future<File> moveFile(File sourceFile, String newPath) async {
  try {
    // prefer using rename as it is probably faster
    return await sourceFile.rename(newPath);
  } on FileSystemException catch (e) {
    e;
    // if rename fails, copy the source file and then delete it
    final newFile = await sourceFile.copy(newPath);
    await sourceFile.delete();
    return newFile;
  }
}

/// Reads [filepath] as a json Map.
/// If file doesn't exists, returns empty Map.
JsonMap openJson(String filepath) {
  final str = openString(filepath);
  if (str.isEmpty) {
    trace('file "$filepath" doesnt exist. Empty json returned');
    return Map<String, String>.identity();
  }
  return jsonDecode(str) as JsonMap;
}

/// Writes [json] in [filepath], with the option to [beautify] the string.
void saveJson(String filepath, dynamic json, {bool beautify = false}) {
  String str;
  if (json is! String) {
    str = beautify ? prettyJson(json) : jsonEncode(json);
  } else {
    str = json;
  }
  saveString(filepath, str);
}

/// Normalizes [localeString] with [targetSeparator] to have consistency around
/// the naming conventions usage in the CLI (and other tools)
String normLocale(String localeString, [String targetSeparator = '_']) {
  /// take only lang code and country code. (zh_Hant_HK, fr_FR, fr_CA)
  localeString = localeString.trim().toLowerCase();
  localeString = localeString.replaceAll('_', '-');
  final parts = localeString.split('-');
  return <String>[
    parts[0].toLowerCase(),
    if (parts.length > 2) parts[1].titleCase,
    if (parts.length > 2) parts[2].toUpperCase(),
    if (parts.length == 2) parts[1].toUpperCase(),
  ].join(targetSeparator);
  // return .take(2).join(targetSeparator);
}

final _detectExtensions = <String>{}..addAll(['.yaml', '.json']);

/// detect the extension if its valid for watch changes
bool _matchExtension(String path) {
  return _detectExtensions.contains(p.extension(path));
}

/// Watches for changes in the config.yaml and the config.entry_file basedir
/// (where your master strings are).
Future<void> watchChanges() async {
  /// listen to changes in trconfig.yaml
  trace(
      '👀 watch mode enabled for:\n - 📁 ${config.inputYamlDir}: and\n - 🗒 $configPath:');
  print('Press ${yellow('q')} then ${yellow('Enter')} to exit the program');
  _listenConfigChanges();
  _listenMasterStringsFilesChanges();
  await stdin.firstWhere((e) {
    var str = utf8.decode(e);

    /// press q to quit.
    if (str.trim() == 'q') {
      return true;
    }
    return false;
  });
}

/// Listen file changes in master string files.
void _listenMasterStringsFilesChanges() {
  var yamlDir = config.inputYamlDir;
  var watcher = DirectoryWatcher(yamlDir, pollingDelay: Duration(seconds: 1));
  watcher.events.listen((e) {
    if (e.type == ChangeType.ADD || e.type == ChangeType.MODIFY) {
      if (_matchExtension(e.path)) {
        var path = p.canonicalize(e.path);
        if (path.endsWith('pubspec.yaml') || path.contains(configPath)) {
          return;
        }
        FTSCommandRunner.instance.watchRunDataSource(path);
      }
    } else {
      /// run cleanup
      // trace('Master string file removed, pending cleanup.');
    }
  });
}

/// Listen
void _listenConfigChanges() {
  var watcher = FileWatcher(configPath);
  watcher.events.listen((event) {
    if (event.type == ChangeType.MODIFY) {
      trace('config changed..');
      FTSCommandRunner.instance.watchRun();
    }
  });
}
