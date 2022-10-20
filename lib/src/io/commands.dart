import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:args/src/arg_parser.dart';
import 'package:dcli/dcli.dart';
import 'package:flutter_translation_sheet/flutter_translation_sheet.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as p;
import '../runner.dart';

/// Command logic for `fts extract`
class ExtractStringCommand extends Command<int> {
  @override
  final String description = 'Extract Strings from dart files';

  @override
  final String name = 'extract';
  final Future Function() exec;

  ExtractStringCommand(this.exec) {
    argParser.addOption('path',
        abbr: 'p',
        help: 'Set the /lib folder to search for Strings in dart files.');
    argParser.addOption('output',
        defaultsTo: 'strings.yaml',
        abbr: 'o',
        help: 'Sets the output path for the generated json map.');
    argParser.addOption('ext',
        defaultsTo: 'dart',
        abbr: 'e',
        help:
            'Comma separated list of allowed file extensions types to analyze for strings.');
    argParser.addFlag('permissive',
        abbr: 's',
        help:
            'Toggles permissive mode, capturing strings without spaces in it.');
    addConfigOption(argParser);
  }

  @override
  Future<int> run() async {
    libFolder = '';
    extractStringOutputFile = absolute('strings.yaml');
    if (argResults!.wasParsed('output')) {
      extractStringOutputFile = argResults!['output']!.trim();
    }
    if (argResults!.wasParsed('ext')) {
      extractAllowedExtensions = argResults!['ext']!.trim();
    }
    if (argResults!.wasParsed('permissive')) {
      extractPermissive = argResults!['permissive']!;
    }
    if (argResults!.wasParsed('path')) {
      libFolder = argResults!['path']!.trim();
    }
    await exec();
    return 0;
  }
}

/// Command logic for `fts fetch`
class FetchCommand extends Command<int> {
  @override
  final String description = 'Fetches the data from the sheet';

  @override
  final String name = 'fetch';
  final Future Function() exec;

  FetchCommand(this.exec) {
    addConfigOption(argParser);
  }

  @override
  Future<int> run() async {
    readPubSpec();
    setConfig(argResults!);
    await exec();
    return 0;
  }
}

/// Command logic for `fts upgrade`
class UpgradeCommand extends Command<int> {
  @override
  final String description = 'Upgrade FTS to the latest version';

  @override
  final String name = 'upgrade';
  final Future<void> Function() exec;

  UpgradeCommand(this.exec);

  @override
  Future<int> run() async {
    await exec();
    return 0;
  }
}

/// Command logic for `fts run`
class RunCommand extends Command<int> {
  @override
  final String description =
      '(default) Runs the strings parsing, starts the sync process with GoogleSheet, fetches the translations, and generates the files.';

  @override
  final String name = 'run';
  final Future Function() exec;

  RunCommand(this.exec) {
    argParser.addFlag(
      'watch',
      abbr: 'w',
      help:
          'Watch the master strings root directory (config.entry_file parent folder) for file changes and also listen for changes on trconfig.yaml',
    );
    addConfigOption(argParser);
  }

  @override
  Future<int> run() async {
    setConfig(argResults!);
    if (argResults != null) {
      if (argResults!.wasParsed('watch')) {
        watchFileChanges = argResults!['watch'];
      }
    }

    await exec();
    return 0;
  }
}

/// Command logic for `fts init`
class InitCommand extends Command<int> {
  @override
  final String description =
      'generates and setup the trconfig.yaml and templates';

  @override
  final String name = 'init';
  final Future<void> Function() exec;

  InitCommand(this.exec) {
    argParser.addOption(
      'credentials',
      abbr: 'c',
      valueHelp: 'The path to credentials.json',
      mandatory: true,
      help: 'Google Service credentials json',
    );
  }

  @override
  Future<int> run() async {
    if (argResults != null) {
      if (argResults!.wasParsed('credentials')) {
        setCredentials(path: argResults!['credentials']);
      }
    }
    if (!config.isValidCredentials()) {
      error('''Invalid path to Google Sheet credentials:

Usage:
fts init --credentials path/to/credentials

${white("How to get your credentials?", bold: true)} 
https://github.com/roipeker/flutter_translation_sheet/wiki/Google-credentials
''');
      exit(2);
    }
    await exec();
    return 0;
  }
}

/// Adds the `config` argument [argParser]
void addConfigOption(ArgParser argParser) {
  argParser.addOption(
    'config',
    abbr: 'c',
    valueHelp: 'trconfig.yaml path',
    help: 'Set the trconfig.yaml path to process',
    defaultsTo: 'trconfig.yaml',
  );
}

/// Reads the `config` from [res]
void setConfig(ArgResults res) {
  if (res.wasParsed('config')) {
    startConfig(res['config']);
  } else {
    readPubSpec();
    var ftsKey = pubSpecMap['fts'];
    if (ftsKey != null) {
      if (ftsKey is String) {
        /// path.
        startConfig(ftsKey);
      } else if (ftsKey is YamlMap) {
        /// map.
        loadEnv(parsedDoc: ftsKey);
      } else {
        error("Invalid `fts` key in pubspec.yaml");
        exit(1);
      }
    } else {
      startConfig('trconfig.yaml');
    }
  }
}

String pubSpecStr = '';
Map pubSpecMap = {};

/// Adds the json files directory. to pubspec.yaml assets.
void addAssetsToPubSpec() {
  if (pubSpecStr.isEmpty) {
    readPubSpec();
  }
  var addAsset = p.dirname(config.outputJsonTemplate) + '/';
  var out = pubSpecStr;
  var assets = pubSpecMap['flutter']?['assets'];
  var replacer = '';
  if (assets == null) {
    replacer = kNoAssetsReplace.replaceAll('##replace', addAsset);
    out = out.replaceAll(kNoAssetsKey, replacer);
  } else {
    // check if the key is already added
    var hasAsset = false;
    if (assets is List) {
      for (String asset in assets) {
        if (asset.contains(addAsset)) {
          hasAsset = true;
        }
      }
    }
    if (!hasAsset) {
      replacer = kHasAssetsReplace.replaceAll('##replace', addAsset);
      out = out.replaceAll(kHasAssetsKey, replacer);
    }
  }
  if (out != pubSpecStr) {
    saveString('pubspec.yaml', out);
  }
}

/// Reads the pubspec.yaml file and stores it in [pubSpecStr] and [pubSpecMap]
void readPubSpec() {
  final file = File('pubspec.yaml');
  if (!file.existsSync()) {
    error("Can't locate pubspec.yaml, run fts from your project root.");
    exit(3);
  }
  pubSpecStr = openString(file.path);
  pubSpecMap = loadYaml(pubSpecStr) as Map;
}

/// Initializes the supplied configuration from [path]
void startConfig(String path) {
  if (path.isEmpty) {
    error(
        'Pass the trconfig.yaml path to --config, or add `fts` to pubspec.yaml');
    exit(1);
  }
  var f = File(path);
  if (!f.existsSync()) {
    error('Error: $path config file not found');

    /// ask to create from template.
    var useCreateTemplate = confirm(
        yellow(
            'Do you wanna create the template (trconfig.yaml) in the current directory?'),
        defaultValue: true);
    if (!useCreateTemplate) {
      var m1 = grey('${CliConfig.cliName} run', background: AnsiColor.black);
      var m2 = grey('${CliConfig.cliName} -h', background: AnsiColor.black);
      var msg =
          '${white('Use', bold: false)} $m1 with a configuration file or see $m2 for more help.';
      print(msg);
      // trace(' trcli again with a configuration file or check trcli -h for more help.');
      exit(0);
    } else {
      /// create template!
      createSampleContent();
    }
  } else {
    loadEnv(
      path: path,
    );
  }
}
