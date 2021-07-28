import 'dart:io';

import 'package:flutter_translation_sheet/src/runner.dart';

/// entry point of the program.
/// Delegates arguments to the CommandRunner.
Future<void> main(List<String> args) async {
  await _checkEnviroment();
  exit(await FTSCommandRunner().run(args));
}

/// Initializes the execution enviroment for the script.
/// [CliConfig.isDev] is `true` when runs locally.
Future<void> _checkEnviroment() async {
  CliConfig.isDev = Platform.script.toFilePath() == 'main.dart';
  return;
}
