import 'dart:io';


import 'package:flutter_translation_sheet/src/runner.dart';


Future<void> main(List<String> args) async {
  await _checkEnviroment();
  exit(await FTSCommandRunner().run(args));
}

Future<void> _checkEnviroment() async {
  CliConfig.isDev = Platform.script.toFilePath() == 'main.dart';
  return;
}
