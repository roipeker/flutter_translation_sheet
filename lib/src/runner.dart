import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:io/io.dart';

import 'data/strings.dart';
import 'io/android_gen.dart';
import 'io/io.dart';
import 'utils/locales_list.dart';
import 'utils/utils.dart';

export 'data/strings.dart';

bool watchFileChanges = false;

/// Command Runner
class FTSCommandRunner extends CommandRunner<int> {
  static late FTSCommandRunner instance;

  FTSCommandRunner()
      : super(
          CliConfig.cliName,
          'cli to make your app\'s l10n easy',
        ) {
    instance = this;
    addCommand(FetchCommand(startFetch));
    addCommand(RunCommand(startRun));
    addCommand(UpgradeCommand(checkUpdate));
    addCommand(ExtractStringCommand(extractStrings));
    addCommand(LocaleSelectionCommand(showGoogleLocaleList));

    argParser.addFlag(
      'version',
      help: 'Shows the current fts version',
      negatable: false,
    );
  }

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final args0 = parse(args);
      return await runCommand(args0) ?? ExitCode.success.code;
      // final cmd = _args.command?.name;
      // if (cmd != 'upgrade') {
      //   await checkUpdate(false);
      // }
      // return res;
    } catch (e) {
      error(e);
    }
    return ExitCode.usage.code;
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    if (topLevelResults['version'] == true) {
      await printVersion();
      return ExitCode.success.code;
    }

    return super.runCommand(topLevelResults);
  }

  var baseCanoMap = <String, String>{};

  /// executes the logic for `fts run`
  Future<void> startRun() async {
    if (watchFileChanges) {
      await watchChanges();
    } else {
      await execRun();
    }
    exit(0);
  }

  /// executes the logic for `fts fetch`
  Future<void> startFetch() async {
    await runFetch();
    exit(0);
  }

  bool isRunActive = false;

  Future<void> watchRunDataSource(String changePath) async {
    if (isRunActive) {
      return;
    }
    trace('Some Data changed. ', changePath);
    await execRun();
  }

  void watchRun() async {
    if (isRunActive) {
      return;
    }
    sheet.reset();
    startConfig(configPath);
    await execRun();
  }

  Future<void> execRun() async {
    isRunActive = true;

    /// save json
    var masterMap = buildLocalYamlMap();
    baseCanoMap = buildCanoMap(masterMap);
    buildVarsInMap(baseCanoMap);

    /// master language?
    // saveLocaleAsset(config.masterLocale, canoMap);
    await sheet.imtired(baseCanoMap);

    trace('⏱ Wait to get the master data translated');
    await Future.delayed(Duration(seconds: 1));

    final localesMap = await sheet.getData();
    localesMap[config.masterLocale] = baseCanoMap;
    putVarsInMap(localesMap);
    createLocalesFiles(localesMap, masterMap);
    formatDartFiles();
    if (config.hasOutputArbDir) {
      buildArb(localesMap);
    }

    /// add locales in iOS
    addLocalesInPlist();
    addLocalesInAndroid();
    flutterHotReload();
    trace('👍 Sync process complete');
    isRunActive = false;
  }

  Future<void> runFetch() async {
    trace('Creating local canonical json');
    var masterMap = buildLocalYamlMap();
    var canoMap = buildCanoMap(masterMap);
    // trace("Map is: ", canoMap);
    // exit(0);
    buildVarsInMap(canoMap);
    // var _tmp = {'en': canoMap};
    // putVarsInMap(_tmp);
    // if (config.intlEnabled) {
    //   buildArb(_tmp);
    // }
    // exit(0);
    trace('Fetching data from Google sheets...');
    final localesMap = await sheet.getData();
    localesMap[config.masterLocale] = canoMap;
    putVarsInMap(localesMap);
    createLocalesFiles(localesMap, masterMap);
    formatDartFiles();
    if (config.hasOutputArbDir) {
      buildArb(localesMap);
    }

    /// add locales in iOS
    addLocalesInPlist();
    addLocalesInAndroid();
    flutterHotReload();
  }
}
