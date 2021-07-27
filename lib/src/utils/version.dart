import 'dart:convert';
import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

import '../data/strings.dart';
import 'logger.dart';
import 'utils.dart';

Future<void> upgrade() async {
  if (which('flutter').found) {
    trace(green('Upgrading fts....\n'));
    final result =
        'flutter pub global activate flutter_translation_sheet'.start(
      terminal: true,
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

Future<void> printVersion() async {
  final current = await currentVersion();
  if (current == null) {
    error('There was an error reading the current version');
  } else {
    trace(green(current));
  }
}

Future<String?> currentVersion() async {
  var scriptFile = Platform.script.toFilePath();
  if (CliConfig.isDev) {
    final str = openString('pubspec.yaml');
    if (str.isEmpty) return null;
    final data = loadYaml(str);
    if (data is YamlMap) {
      return data['version'];
    }
  }
  // trace('script file: ', basename(scriptFile));
  var pathToPubLock =
      canonicalize(join(dirname(scriptFile), '../pubspec.lock'));
  var str = openString(pathToPubLock);
  if (str.isEmpty) return null;
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

Future<void> checkUpdate([bool fromCommand = true]) async {
  if (CliConfig.isDev) return;

  if (fromCommand) {
    trace('\nChecking for updates...');
  }

  try {
    final latest = await _checkLatestVersion();
    if (latest == null) {
      error('cannot fetch the latest version');
      return;
    }
    final current = await currentVersion();
    if (current == null) {
      if (fromCommand) {
        error('there was an error reading the current version');
      }
      return;
    }
    final compare = compareSemver(current, latest);
    if (compare >= 0) {
      if (fromCommand) {
        trace(cyan('fts already on the latest version'));
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
/// 0 if its the same
/// from `cli_notify`
int compareSemver(String version, String other) {
  final regExp = RegExp(
    r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(-[a-zA-Z\d][-a-zA-Z.\d]*)?(\+[a-zA-Z\d][-a-zA-Z.\d]*)?$',
  );
  try {
    if (regExp.hasMatch(version) && regExp.hasMatch(other)) {
      final versionMatches = regExp.firstMatch(version);
      final otherMatches = regExp.firstMatch(other);

      var result = 0;

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
