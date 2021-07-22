import 'dart:io';

// import 'package:dcli/dcli.dart';
import 'package:args/command_runner.dart';
import 'package:fts_cli/fts_cli.dart';

Future<void> main(List<String> args) async {
  var runner = CommandRunner(
    AppStrings.cliName,
    'cli to make your app\'s l10n easy',
  )
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
  // trace("Start run!");
  build();
}

Future<void> startFetch() async {
  trace('Creating local canonical json');
  var map = buildLocalYamlMap();
  var canoMap = buildCanoMap(map);
  trace('Fetching data from Google sheets...');
  final localesMap = await sheet.getData();
  localesMap[config.masterLocale] = canoMap;
  putVarsInMap(localesMap);

  if (config.validTKeyFile) {
    createTKeyFileFromMap(map, save: true, includeToString: true);
  }
  createLocalesFiles(localesMap);
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
  formatDartFiles();
  exit(1);
}
