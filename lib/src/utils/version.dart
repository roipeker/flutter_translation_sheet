import 'dart:convert';
import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../data/strings.dart';
import 'utils.dart';

/// runs the [upgrade] command: `fts upgrade`
Future<void> upgrade() async {
  if (which('flutter').found) {
    trace(green('Upgrading fts (global package) ...\n'));
    final result =
        'flutter pub global activate flutter_translation_sheet'.start(
      runInShell: true,
      progress: Progress(
        (e) => trace(yellow(e, bold: false)),
        stderr: printerr,
      ),
    );

    if (result.exitCode == 0) {
      trace(green('\nfts upgraded to the latest version'));
    }
    exit(1);
  }
}

/// shows the version number in the Terminal.
Future<void> printVersion() async {
  final current = currentVersion();
  if (current == null) {
    error('There was an error reading the current version');
  } else {
    trace(green(current));
  }
}

/// Returns the current fts version.
/// Validating if it runs in local mode [CliConfig.isDev], or installed as
/// snapshot.
String? currentVersion() {
  var scriptFile = Platform.script.toFilePath();
  if (CliConfig.isDev) {
    /// navigate up in the folders up to the project dir
    /// ./flutter_translation_sheet/.dart_tool/pub/bin/flutter_translation_sheet/
    var basePath = p.dirname(scriptFile);
    basePath = p.dirname(basePath);
    basePath = p.dirname(basePath);
    basePath = p.dirname(basePath);
    basePath = p.dirname(basePath);
    var pubSpec = p.join(basePath, 'pubspec.yaml');
    final str = openString(pubSpec);
    if (str.isEmpty) return null;
    final data = loadYaml(str);
    if (data is YamlMap) {
      return 'dev-' + data['version'];
    }
    return 'Could not find pubspec.yaml version in local enviroment.';
  }
  // trace('script file: ', basename(scriptFile));
  var pathToPubLock =
      canonicalize(join(dirname(scriptFile), '../pubspec.lock'));
  var str = openString(pathToPubLock);
  if (str.isEmpty) {
    return null;
  }
  var yaml = loadYaml(str);
  if (yaml['packages'][CliConfig.packageName] == null) {
    /// running local version? might read the pubspec here.
    var pathToPubSpec =
        canonicalize(join(dirname(pathToPubLock), 'pubspec.yaml'));
    str = openString(pathToPubSpec);
    if (str.isEmpty) {
      /// Impossible scenario. But just in case.
      error('Report version error to the developers of the package.');
      return null;
    }
    yaml = loadYaml(str);
    var version = yaml['version'];
    return version;
  } else {
    var version = yaml['packages'][CliConfig.packageName]['version'].toString();
    return version;
  }
}

/// Command to run from `fts upgrade` or automatically after all executions.
/// Checks if there's a new version available on pub.dev and allows the user
/// to install them.
Future<void> checkUpdate([bool fromCommand = true]) async {
  // if (CliConfig.isDev) {
  //   trace('\nCan\'t update when running on dev enviroment');
  //   return;
  // }
  if (fromCommand) {
    trace('\nChecking for updates...');
  }

  try {
    final latest = await _checkLatestVersion();
    if (latest == null) {
      if (fromCommand) {
        error('Cannot fetch the latest published version');
      }
      return;
    }
    final current = currentVersion();
    if (current == null) {
      if (fromCommand) {
        error('There was an error reading the current version');
      }
      return;
    }
    final compare = compareSemver(current, latest);
    if (compare >= 0) {
      if (fromCommand) {
        trace(cyan('You are using the latest version of fts.'));
      }
      return;
    }
    final c = orange(current);
    final l = green(latest);
    trace(
      yellow(
        '___________________________________________________\n\n',
      ),
    );
    trace(cyan('Update available ', bold: true));
    trace('\n$c -> $l\n');
    // blue();
    trace(
      'Changelog: ${blue("https://pub.dev/packages/${CliConfig.packageName}/changelog")}',
    );
    trace(
      yellow(
        '\n___________________________________________________\n\n',
      ),
    );
    final result = confirm(
      yellow('Would you like update to the last version?'),
      defaultValue: true,
    );
    if (result) {
      return upgrade();
    }
  } on Exception {
    return;
  }
}

/// Retrieves the latest version from pub.dev for [CliConfig.packageName]
Future<String?> _checkLatestVersion() async {
  try {
    final response = await http.get(
      Uri.parse('https://pub.dev/api/packages/${CliConfig.packageName}'),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final result = data['latest']['version'] as String;
    return result;
  } on Exception {
    return null;
  }
}

/// Compares a [version] against [other]
/// returns negative if [version] is ordered before
/// positive if [version] is ordered after
/// Doesnt considere incremental builds +VALUE
/// 0 if its the same
/// from `cli_notify`
int compareSemver(String version, String other) {
  version = version.replaceAll('dev-', '');
  other = other.replaceAll('dev-', '');

  final regExp = RegExp(
    r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(-[a-zA-Z\d][-a-zA-Z.\d]*)?(\+[a-zA-Z\d][-a-zA-Z.\d]*)?$',
  );
  try {
    if (regExp.hasMatch(version) && regExp.hasMatch(other)) {
      final versionMatches = regExp.firstMatch(version);
      final otherMatches = regExp.firstMatch(other);

      var result = 0;
      // print("versions $versionMatches -- $otherMatches");
      if (versionMatches == null || otherMatches == null) {
        return result;
      }

      final isPrerelease = otherMatches.group(4) != null ? true : false;
      // Ignore if its pre-release
      if (isPrerelease) {
        return result;
      }

      for (var idx = 1; idx < versionMatches.groupCount; idx++) {
        final versionMatch = versionMatches.group(idx) ?? '';
        final otherMatch = otherMatches.group(idx) ?? '';
        // PreRelease group
        final versionNumber = int.tryParse(versionMatch);
        final otherNumber = int.tryParse(otherMatch);
        if (versionMatch != otherMatch) {
          if (versionNumber == null || otherNumber == null) {
            result = versionMatch.compareTo(otherMatch);
          } else {
            result = versionNumber.compareTo(otherNumber);
          }
          break;
        }
      }

      return result;
    }

    return 0;
  } on Exception catch (err) {
    print(err.toString());
    return 0;
  }
}
