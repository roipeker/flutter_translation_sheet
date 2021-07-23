import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_translation_sheet/flutter_translation_sheet.dart';

Future<void> main(List<String> args) async {
  var runner = CommandRunner(
    AppStrings.cliName,
    'cli to make your app\'s l10n easy',
  )
    ..addCommand(ExtractStringCommand(extractStrings))
    ..addCommand(FetchCommand(startFetch))
    ..addCommand(RunCommand(startRun));
  try {
    var res = await runner.run(args).onError((err, stackTrace) {
      error(err);
    });
  } catch (e) {
    error(e);
  }
}

void startRun() {
  build();
}

Future<void> startFetch() async {
  trace('Creating local canonical json');
  var map = buildLocalYamlMap();
  var canoMap = buildCanoMap(map);
  // trace("Map is: ", canoMap);
  // exit(0);
  buildVarsInMap(canoMap);
  // var _tmp = {'en':canoMap};
  // putVarsInMap(_tmp);
  trace('Fetching data from Google sheets...');
  final localesMap = await sheet.getData();
  localesMap[config.masterLocale] = canoMap;
  putVarsInMap(localesMap);
  if (config.validTKeyFile) {
    createTKeyFileFromMap(map, save: true, includeToString: true);
  }
  createLocalesFiles(localesMap);
  if (config.intlEnabled) {
    buildArb(localesMap);
  }
  formatDartFiles();
  exit(1);
}

Future<void> build() async {
  /// save json
  var map = buildLocalYamlMap();
  var canoMap = buildCanoMap(map);
  buildVarsInMap(canoMap);

  /// master language?
  // saveLocaleAsset(config.masterLocale, canoMap);
  await sheet.imtired(canoMap);

  trace('wait a sec to get the data translated');
  await Future.delayed(Duration(seconds: 1));

  final localesMap = await sheet.getData();
  localesMap[config.masterLocale] = canoMap;
  putVarsInMap(localesMap);

  /// create tkey file
  if (config.validTKeyFile) {
    createTKeyFileFromMap(map, save: true, includeToString: true);
  }
  createLocalesFiles(localesMap);
  if (config.intlEnabled) {
    buildArb(localesMap);
  }
  formatDartFiles();
  exit(1);
}
