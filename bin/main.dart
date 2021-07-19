import 'dart:io';

// import 'package:dcli/dcli.dart';
import 'package:dcli/dcli.dart';
import 'package:trcli/translate_cli.dart';

final _parser = ArgParser();

void main(List<String> args) {
  _parser.addFlag(
    'help',
    abbr: 'h',
    negatable: false,
    help: 'Shows the help.',
  );
  _parser.addOption(
    'config',
    abbr: 'c',
    help: 'Set the trconfig.yaml path to process',
  );
  // ..addCommand('create')
  // ..addCommand('download');
  try {
    final res = _parser.parse(args);
    if (res.wasParsed('help')) {
      _showUsage();
      exit(0);
    }
    startConfig(res['config'] ?? 'trconfig.yaml');
  } catch (e) {
    error('ERROR: $e');
  }
  // if (res.command?.name == 'create') {
  //   _runCreate();
  // } else if (res.command?.name == 'download') {
  //   _runDownload();
  // } else {
  //
  // }
}

void _showUsage() {
  trace('''Usage: 
    ${_parser.usage}
''');
}

void startConfig(String path) {
  // trace('start config on: ', path);
  if (path.isEmpty) {
    error('Pass the trconfig.yaml path to -c');
    exit(1);
  }
  var f = File(path);
  if (!f.existsSync()) {
    error('Error: $path config file not found');

    /// ask to create from template.
    var useCreateTemplate = confirm(
        yellow(
            'Do you wanna create the template trconfig.yaml in the current directory?'),
        defaultValue: true);
    if (!useCreateTemplate) {
      var m1 = grey('trcli', background: AnsiColor.black);
      var m2 = grey('trcli -h', background: AnsiColor.black);
      var msg =
          'run $m1 again with a configuration file or check $m2 for more help.';
      print(msg);
      // trace(' trcli again with a configuration file or check trcli -h for more help.');
      exit(0);
    } else {
      /// create template!
      createSampleContent();
    }
  } else {
    loadEnv(path);
    build();
  }
}

void _runCreate() {
  trace('run create!');
}

void _runDownload() {
  trace('run download!');
}

Future<void> build() async {
  /// save json
  var map = buildLocalYamlMap();
  var canoMap = buildCanoMap(map);

  /// master language?
  // saveLocaleAsset(config.masterLocale, canoMap);
  await sheet.imtired(canoMap);

  trace('wait a sec to get the data translated');
  await Future.delayed(Duration(seconds: 1));

  final localesMap = await sheet.getData();

  localesMap[config.masterLocale] = canoMap;

  /// create tkey file
  if (config.validTKeyFile) {
    createTKeyFileFromMap(map, save: true, includeToString: false);
  }
  createLocalesFiles(localesMap);

  formatDartFiles();
  exit(1);

  //   var hasData = await sheet.hasData();
  // if(!hasData){
  //   /// setup table.
  //   await sheet.buildStructure(config.locales, map);
  //   // trace(config.locales);
  //   trace(map);
  // }
  // trace('Sheet result: \n', dataResult);
}
