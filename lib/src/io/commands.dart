import 'dart:io';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:args/src/arg_parser.dart';
import 'package:dcli/dcli.dart';
import 'package:flutter_translation_sheet/flutter_translation_sheet.dart';

class FetchCommand extends Command<int> {
  @override
  final String description = 'Fetches the data from the sheet';

  @override
  final String name = 'fetch';
  final Function exec;
  FetchCommand(this.exec) {
    addConfigOption(argParser);
  }

  @override
  Future<int> run() async {
    setConfig(argResults!);
    exec();
    return 0;
  }
}

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

class RunCommand extends Command<int> {
  @override
  final String description =
      'Runs the strings parsing, starts the sync process with GoogleSheet, fetches the translations, and generates the files.';

  @override
  final String name = 'run';
  final Function exec;

  RunCommand(this.exec) {
    addConfigOption(argParser);
  }

  @override
  Future<int> run() async {
    setConfig(argResults!);
    exec();
    return 0;
  }
}

void addConfigOption(ArgParser argParser) {
  argParser.addOption(
    'config',
    abbr: 'c',
    valueHelp: 'trconfig.yaml path',
    help: 'Set the trconfig.yaml path to process',
    defaultsTo: 'trconfig.yaml',
  );
}

void setConfig(ArgResults res) {
  if (res.wasParsed('config')) {
    startConfig(res['config']);
  } else {
    /// use default!
    startConfig('trconfig.yaml');
  }
}

void startConfig(String path) {
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
      var m1 = grey('${CliConfig.cliName} run', background: AnsiColor.black);
      var m2 = grey('${CliConfig.cliName} -h', background: AnsiColor.black);
      var msg = '$m1 with a configuration file or see $m2 for more help.';
      print(msg);
      // trace(' trcli again with a configuration file or check trcli -h for more help.');
      exit(0);
    } else {
      /// create template!
      createSampleContent();
    }
  } else {
    loadEnv(path);
  }
}
