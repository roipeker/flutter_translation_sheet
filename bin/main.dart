import 'dart:io';

import 'package:flutter_translation_sheet/src/runner.dart';
Future<void> main(List<String> args) async {
  exit(await FTSCommandRunner().run(args));
}

