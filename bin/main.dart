import 'dart:io';

// import 'package:dcli/dcli.dart';
import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';
import 'package:trcli/translate_cli.dart';

import '../lib/src/io/commands.dart';

final _parser = ArgParser();

Future<void> main(List<String> args) async {
  // testMapper();
  // return;
  var runner = CommandRunner(
    'trcli',
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

// var keys = {};

// void testMapper() {
//   // var str = 'Welcome back {{user}}, today is {{date}}.';
//   // var params = captureVars(str);
//   // str = params.text;
//   // trace('super intput ' ,str);
//   // var output = replaceVars(params);
//   // trace('super output ' ,output);
//   // trace(params.text);
//   // trace(params.vars);
// }

// String trArgs2(List<dynamic> params) {
//   var str = tr;
//   if (_matchParamsRegExp.hasMatch(str)) {
//     // deduplicate matches
//     final wordset = <String>{};
//     final matches = _matchParamsRegExp.allMatches(str);
//     for (var match in matches) {
//       wordset.add(str.substring(match.start, match.end));
//     }
//     // Replacing
//     var words = wordset.toList();
//     for (var i = 0; i < words.length; i++) {
//       str = str.replaceAll(words[i], '${params[i]}');
//     }
//   }
//   return str;
// }

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
  if (config.validTKeyFile) {
    createTKeyFileFromMap(map, save: true, includeToString: false);
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
    createTKeyFileFromMap(map, save: true, includeToString: false);
  }
  createLocalesFiles(localesMap);
  formatDartFiles();
  exit(1);
}
