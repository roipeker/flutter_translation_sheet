import 'dart:io';

import 'package:flutter_translation_sheet/src/gsheets/gsheets.dart';
import 'package:flutter_translation_sheet/src/runner.dart';
import 'package:flutter_translation_sheet/src/utils/errors.dart';

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

/// Initializes the execution environment for the script.
/// [CliConfig.isDev] is `true` when runs locally.
void _checkEnvironment() async {
  CliConfig.isDev = Platform.script.toString().endsWith('main.dart');
}
