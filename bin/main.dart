import 'dart:io';

import 'package:flutter_translation_sheet/src/gsheets/gsheets.dart';
import 'package:flutter_translation_sheet/src/runner.dart';
import 'package:flutter_translation_sheet/src/utils/errors.dart';
import 'package:flutter_translation_sheet/src/utils/utils.dart';
import 'package:path/path.dart';

/// entry point of the program.
/// Delegates arguments to the CommandRunner.
Future<void> main(List<String> args) async {
  _checkEnvironment();
  try {
    if (args.isEmpty) {
      args = ['run'];
    }
    exit(await FTSCommandRunner().run(args));
  } on GSheetsException catch (e) {
    gsheetError(e);
    rethrow;
  }
}

void testEnv() {}

/// Initializes the execution environment for the script.
/// [CliConfig.isDev] is `true` when runs locally.
void _checkEnvironment() async {
  var pathToPubLock = canonicalize(
      join(dirname(Platform.script.toFilePath()), '../pubspec.lock'));
  CliConfig.isDev = !File(pathToPubLock).existsSync();
}

/// for dev:
/// flutter pub global deactivate flutter_translation_sheet;flutter pub global activate -s path "/Volumes/mydata/dev/repos/flutter_translation_sheet"
