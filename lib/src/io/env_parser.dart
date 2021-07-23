import 'dart:io';

import 'package:flutter_translation_sheet/flutter_translation_sheet.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../utils/utils.dart';

const defaultConfigEnvPath = 'trconfig.yaml';
EnvConfig config = EnvConfig._();
String configPath = '';

String get configProjectDir {
  return p.dirname(configPath);
}

void createSampleConfig() {
  saveString(defaultConfigEnvPath, _kSampleConfig);
  trace('''Please, fill
  
gsheet:
  credentials_path:
  spreadsheet_id:
  worksheet:
  
in $defaultConfigEnvPath and run the command again.''');
}

void loadEnv([String path = defaultConfigEnvPath]) {
  var data = openString(path);
  if (data.isEmpty) {
    trace(
        'ERROR: "$defaultConfigEnvPath" file not found, creating from template.');
    createSampleConfig();
    exit(0);
  }
  configPath = p.canonicalize(path);
  var doc = loadYaml(data);
  config.intlEnabled = doc['intl']?['enabled'] ?? false;
  config.outputJsonDir = doc['output_json_dir'] ?? 'output/assets/l10n';
  config.entryFile = doc['entry_file'] ?? '';
  config.dartOutputDir = doc?['dart']?['output_dir'] ?? '';
  config.dartTKeysId = doc?['dart']?['keys_id'] ?? '';
  config.useDartMaps = doc?['dart']?['use_maps'] ?? false;
  config.dartTranslationsId = doc?['dart']?['translations_id'] ?? '';
  config.paramOutputPattern = doc?['param_output_pattern'] ?? '';
  _configParamOutput();

  if (config.entryFile.isNotEmpty) {
    var f = File(config.entryFile);
    if (!f.existsSync()) {
      trace(
          '''ERROR: $defaultConfigEnvPath, [entry_file: "${config.entryFile}"] doesn't exists.
Please, create your data tree.''');
      exit(32);
    }
  }

  if (doc?['locales'] != null) {
    final l = doc['locales'];
    if (l is YamlList) {
      config.locales = List<String>.from(l).toSet().toList(growable: false);
      config.locales =
          config.locales.map((e) => normLocale(e)).toList(growable: false);

      /// validate locale existence?
      print('Using config locales:');
      const _sep = ' - ';
      for (var locale in config.locales) {
        trace(_sep, langInfoFromKey(locale));
      }
      // config.locales.removeWhere((element) => element.isEmpty);
      // trace('config locales: ', config.locales);
    }
  }
  if (config.locales.isEmpty) {
    trace('''ERROR: $defaultConfigEnvPath: [locales:] not defined. 
Add at least 1, like "en" or "es", reflecting the master language locale you use in [entry_file].
Remember, the first item in the [locales:] is the master locale... the one you use to translate to other locales.
This list takes all the locales you will process in GoogleSheet, and has to be valid locale names.
See https://cloud.google.com/translate/docs/languages for a list of supported translation locales. 
''');
    exit(2);
  }

  if (doc is YamlMap) {
    if (doc['gsheets'] != null) {
      _parseSheets(doc['gsheets']);
      if (config.sheetId == null) {
        trace(
            'ERROR: $defaultConfigEnvPath: [gsheets:spreadsheet_id] not defined, get it from the GoogleSheet url: '
            'https://docs.google.com/spreadsheets/d/{HERE}');
        exit(2);
      }
      if (config.tableId == null) {
        trace(
            '$defaultConfigEnvPath: [gsheets:worksheet] not defined, add it.');
        exit(2);
      }
      trace('Spreadsheet id: ', config.sheetId);
      trace('Worksheet title: "', config.tableId, '"');
    } else {
      trace(
          'ERROR: $defaultConfigEnvPath: [ghseets] configuration not found, please edit $defaultConfigEnvPath.');
      exit(1);
    }
  }

  if (config.useIterativeCache) {
    warning('[config:gsheet:use_iterative_cache:] is enabled.');
//     warning(
//         '''WARNING: [config:gsheet:use_iterative_cache:] is enabled.
// For a performance boost on big datasets, the values inserted tries to use the GoogleTranslate formula once.
//
// Enable "iterative calculations" manually in your worksheet to avoid the #VALUE error.
//
// Go to:
// File > Spreadsheet Settings > Calculation > set "Iterative calculation" to "On"
//
// Or check:
// https://support.google.com/docs/answer/58515?hl=en&co=GENIE.Platform%3DDesktop#zippy=%2Cchoose-how-often-formulas-calculate
// ''');
  } else {
    trace('[config:gsheet:use_iterative_cache:] is disabled.');
  }
  // config.locales = doc?['locales'] ?? ['en'];
  // trace('env output path: ', config.outputDir);
  // if (config.outputDir.isEmpty) {
  //   throw 'config::outputDir is empty, please check _config_env.yaml file';
  // }
  if (config.entryFile.isEmpty) {
    trace('ERROR: $defaultConfigEnvPath: [entryFile] is empty, please add it.');
    exit(3);
  }
  if (config.outputJsonDir.isEmpty) {
    trace(
        'ERROR: $defaultConfigEnvPath: [outputJsonDir] is empty, please add it.');
    exit(3);
  }
  if (!config._isValidDartConfig()) {
    exit(3);
  }
  _createDir();
}

void _configParamOutput() {
  /// fix param output to valid string.
  var _paramOutput = config.paramOutputPattern;
  if (_paramOutput.isEmpty) {
    _paramOutput = '{*}';
  }
  if (_paramOutput.isNotEmpty && !_paramOutput.contains('*')) {
    trace('''Wrong usage of config:[param_output_pattern:], has to enclose *.
Example: using "name":
(*) = (name) 
%* = %name

If you need the "*" char in your pattern use "*?" as splitter:
***?** = **name** 
Using default {*}''');
    _paramOutput = '{*}';
  }

  /// check if its special split?
  late List<String> _params;
  if (_paramOutput.contains('*?')) {
    _params = _paramOutput.split('*?');
  } else {
    _params = _paramOutput.split('*');
  }
  if (_params.length == 1) {
    /// using empty string.
    config.paramOutputPattern1 = '';
    config.paramOutputPattern2 = '';
  } else {
    if (_params.length == 2) {
      config.paramOutputPattern1 = _params[0];
      config.paramOutputPattern2 = _params[1] == '*' ? '' : _params[1];
    } else {
      config.paramOutputPattern1 = _params[0];
      config.paramOutputPattern2 = _params[2];
    }
  }
}

void _parseSheets(YamlMap doc) {
  var credentials = doc['credentials'];
  var credentialsPath = doc['credentials_path'];
  if (credentials != null) {
    config.sheetCredentials = credentials;
  } else if (credentialsPath != null) {
    var credentialsString = openString(credentialsPath);
    if (credentialsString.isEmpty) {
      error(
          "ERROR: [gsheets:credentials_path:$credentialsPath] doesn\'t exists or is empty.");
      exit(2);
    }
    config.sheetCredentials = credentialsString;
  }
  if (config.sheetCredentials == null) {
    trace(
        '''$defaultConfigEnvPath: Please be sure to include your Google Sheet credentials.
- Use [gsheets:credentials_path:] for a path to your credentials.
- Use [gsheets:credentials:] to paste credentials Json details.

How to get your credentials?
https://medium.com/@a.marenkov/how-to-get-credentials-for-google-sheets-456b7e88c430
''');
    exit(2);
  }
  config.sheetId = doc['spreadsheet_id'];
  config.tableId = doc['worksheet'];
  config.useIterativeCache = doc['use_iterative_cache'] ?? false;
}

void _createDir() {
  // if (!exists(config.outputDir)) {
  //   createDir(config.outputDir, recursive: true);
  //   trace('creating output directory at ${config.outputDir}');
  // }
}

void main() {
  loadEnv();
}

class EnvConfig {
  // String outputDir = 'output';
  String dartOutputDir = '';
  String outputJsonDir = '';
  String entryFile = '';
  String paramOutputPattern = '{*}';
  String paramOutputPattern1 = '{{';
  String paramOutputPattern2 = '}}';
  bool intlEnabled = false;
  // param_output_pattern
  bool useDartMaps = false;

  String get intlYamlPath {
    return !intlEnabled ? '' : joinDir([configProjectDir,'l10n.yaml']);
  }

  String get inputYamlDir {
    if (entryFile.contains('/')) {
      var dirs = entryFile.split('/');
      dirs.removeLast();
      return dirs.join('/');
    }
    return '';
  }

  /// "outputDir + tkeys.dart"
  String dartTKeysId = '';
  String dartTranslationsId = ''; //translations_id

  bool useIterativeCache = false;
  List<String> locales = [];

  String get masterLocale {
    return locales.first;
  }

  String? sheetId, tableId;
  dynamic sheetCredentials;

  String get dartTKeysClassname {
    return dartTKeysId.pascalCase;
  }

  String get dartTranslationClassname {
    return dartTranslationsId.pascalCase;
  }

  String get dartTranslationPath {
    final filename = dartTranslationsId.snakeCase + '.dart';
    return joinDir([dartOutputDir, filename]);
  }

  String get dartTkeysPath {
    final filename = dartTKeysId.snakeCase + '.dart';
    return joinDir([dartOutputDir, filename]);
  }

  EnvConfig._();

  bool get validTKeyFile => dartTKeysId.isNotEmpty;

  bool get validTranslationFile => dartTranslationsId.isNotEmpty;

  String get inputVarsFile => joinDir([config.inputYamlDir, 'vars.lock']);

  bool isValidSheet() =>
      sheetId != null && tableId != null && sheetCredentials != null;

  bool _isValidDartConfig() {
    if (dartOutputDir.isEmpty) {
      if (validTKeyFile) {
        trace(
            '''ERROR: $defaultConfigEnvPath [dart:keys_id:] requires an output directory.
Please, set [dart:output_dir:] to use any dart generation capability.        
''');
        return false;
      }
      if (validTranslationFile) {
        trace(
            '''ERROR: $defaultConfigEnvPath [dart:translations_id:] requires an output directory.
Please, set [dart:output_dir:] to use any dart generation capability.        
''');
        return false;
      }
      return true;
    }
    return true;
  }
}

const _kSampleConfig = '''
## output dir for json translations by locale
output_json_dir: data/output/assets/i18n

## main entry file to generate the unique translation json.
entry_file: data/entry/sample.yaml

## pattern to applies final variables in the generated json/dart Strings.
## Enclose * in the pattern you need.
## {*} = {{name}} becomes {name}
## %* = {{name}} becomes %name
## (*) = {{name}} becomes (name)
## - Special case when you need * as prefix or suffix, use *? as splitter
## ***?** = {{name}} becomes **name**
param_output_pattern: "{*}"

dart:
  ## Output dir for dart files
  output_dir: data/output/src/i18n

  ## Translation Key class and filename reference
  keys_id: Keys

  ## Translations map class an filename reference.
  translations_id: Translations

  ## translations as dart files Maps (available in translations.dart).
  use_maps: false

## see: https://cloud.google.com/translate/docs/languages
## All locales to be supported.
locales:
  - en
  - es
  - ja

## Google Sheets Configuration
## How to get your credentials?
## see: https://medium.com/@a.marenkov/how-to-get-credentials-for-google-sheets-456b7e88c430
gsheets:

  ## For a performance boost on big datasets, to try to use the GoogleTranslate formula once,
  ## enable "Iterative Calculations" manually in your worksheet to avoid the #VALUE error.
  ## Go to:
  ## File > Spreadsheet Settings > Calculation > set "Iterative calculation" to "On"
  ## Or check:
  ## https://support.google.com/docs/answer/58515?hl=en&co=GENIE.Platform%3DDesktop#zippy=%2Cchoose-how-often-formulas-calculate
  use_iterative_cache: false

  credentials_path:

  ## Open your google sheet and get it from the url:
  ## https://docs.google.com/spreadsheets/d/{ID}
  spreadsheet_id:

  ## The spreadsheet "table" where your translation will live.
  worksheet: Sheet1
''';
