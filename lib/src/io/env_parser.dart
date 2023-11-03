import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:flutter_translation_sheet/flutter_translation_sheet.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

const defaultConfigEnvPath = 'trconfig.yaml';
EnvConfig config = EnvConfig._();
String configPath = '';

/// flag that tells us if we have vars to parse or not.
bool entryDataHasVars = false;

/// Speculates the Flutter project dir based on the [configPath] location.
String get configProjectDir {
  return p.canonicalize(p.dirname(configPath));
}

/// Loads the configuration file from [path].
void loadEnv({
  String path = defaultConfigEnvPath,
  YamlMap? parsedDoc,
}) {
  late YamlMap doc;
  if (parsedDoc == null) {
    var data = openString(path);
    if (data.isEmpty) {
      trace(
          'ERROR: "$defaultConfigEnvPath" file not found, creating from template.');
      createSampleConfig();
      exit(0);
    }
    configPath = p.canonicalize(path);
    doc = loadYaml(data);
  } else {
    doc = parsedDoc;
  }

  // config.intlEnabled = doc['intl']?['enabled'] ?? false;
  // config.outputJsonDir = doc['output_json_dir'] ?? '';
  if (doc['output_fts_utils'] != null && doc['output_fts_utils'] is! bool) {
    error('Invalid value for `output_fts_utils` in $path, must be a boolean.');
    exit(1);
  }
  config.outputJsonTemplate = doc['output_json_template'] ?? '';
  config.outputArbTemplate = doc['output_arb_template'] ?? '';
  config._configOutputTemplates();

  ///'output/assets/l10n'
  config.outputAndroidLocales = doc['output_android_locales'] ?? true;
  config.entryFile = doc['entry_file'] ?? '';
  config.dartOutputDir = doc['dart']?['output_dir'] ?? '';
  config.dartOutputFtsUtils = doc['dart']['output_fts_utils'] ?? false;
  config.dartTKeysId = doc['dart']?['keys_id'] ?? '';
  config.useDartMaps = doc['dart']?['use_maps'] ?? false;
  config.dartFormatLineLength = doc['dart']?['format_line_length'] ?? 0;
  config.dartTranslationsId = doc['dart']?['translations_id'] ?? '';
  config.paramOutputPattern = doc['param_output_pattern'] ?? '{*}';
  config.resolveLinkedKeys = doc['resolve_linked_keys'] ?? false;
  config.paramFtsUtilsArgsPattern =
      doc['dart']?['fts_utils_args_pattern'] ?? '%s';

  _configParamOutput();
  if (config.dartOutputDir.isNotEmpty) {
    config.dartOutputDir = p.canonicalize(config.dartOutputDir);
  }
  if (config.entryFile.isNotEmpty) {
    /// clean the URL now.
    config.entryFile = p.canonicalize(config.entryFile);
    config.inputYamlDir = p.dirname(config.entryFile);
    var f = File(config.entryFile);
    if (!f.existsSync()) {
      trace(
          '''ERROR: $defaultConfigEnvPath, [entry_file: "${config.entryFile}"] doesn't exists.
Please, create your data tree.''');
      exit(32);
    }
  }
  if (doc['locales'] != null) {
    final l = doc['locales'];
    if (l is YamlList) {
      config.locales = List<String>.from(l).toSet().toList(growable: false);
      config.locales =
          config.locales.map((e) => normLocale(e)).toList(growable: false);

      /// validate locale existence?
      print('Using config locales:');
      const sep = ' - ';
      for (var locale in config.locales) {
        trace(sep, langInfoFromKey(locale));
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

  if (doc['gsheets'] != null) {
    _parseSheets(doc['gsheets']);
    if (config.sheetId == null) {
      trace(
          'ERROR: $defaultConfigEnvPath: [gsheets:spreadsheet_id] not defined, get it from the GoogleSheet url: '
          'https://docs.google.com/spreadsheets/d/{HERE}');
      exit(2);
    }
    if (config.tableId == null) {
      config.tableId = 'Sheet1';
      trace(
          '$defaultConfigEnvPath: [gsheets:worksheet] not defined, will default to "Sheet1", make sure it matches.');
    }
    var sheetUrl =
        'https://docs.google.com/spreadsheets/d/${config.sheetId}/edit#gid=0';
    print('spreadsheet id:\n - ${magenta(config.sheetId!)}');
    // trace('Worksheet title: "', config.tableId, '"');
    trace('worksheet title:\n - ${magenta(config.tableId!)}');
    trace('🔗 click to edit sheet:\n - $sheetUrl');
  } else {
    trace(
        'ERROR: $defaultConfigEnvPath: [ghseets] configuration not found, please edit $defaultConfigEnvPath.');
    exit(1);
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
  // if (config.outputJsonDir.isEmpty) {
  //   trace(
  //       'ERROR: $defaultConfigEnvPath: [outputJsonDir] is empty, please add it.');
  //   exit(3);
  // }
  if (!config._isValidDartConfig()) {
    exit(3);
  }
}

/// Parses trconfig.yaml `param_output_pattern`.
void _configParamOutput() {
  /// fix param output to valid string.
  var paramOutput = config.paramOutputPattern;
  if (paramOutput.isEmpty) {
    paramOutput = '{*}';
  }
  if (paramOutput.isNotEmpty && !paramOutput.contains('*')) {
    trace('''Wrong usage of config:[param_output_pattern:], has to enclose *.
Example: using "name":
(*) = (name) 
%* = %name

If you need the "*" char in your pattern use "*?" as splitter:
***?** = **name** 
Using default {*}''');
    paramOutput = '{*}';
  }

  /// check if its special split?
  late List<String> params;
  if (paramOutput.contains('*?')) {
    params = paramOutput.split('*?');
  } else {
    params = paramOutput.split('*');
  }
  if (params.length == 1) {
    /// using empty string.
    config.paramOutputPattern1 = '';
    config.paramOutputPattern2 = '';
  } else {
    if (params.length == 2) {
      config.paramOutputPattern1 = params[0];
      config.paramOutputPattern2 = params[1] == '*' ? '' : params[1];
    } else {
      config.paramOutputPattern1 = params[0];
      config.paramOutputPattern2 = params[2];
    }
  }
}

/// Parses info from `gsheet:` tag in the configuration.
void _parseSheets(YamlMap doc) {
  var credentials = doc['credentials'];
  var credentialsPath = doc['credentials_path'];
  setCredentials(path: credentialsPath, json: credentials);
  if (!config.isValidCredentials()) {
    trace(
        '''$defaultConfigEnvPath: Please be sure to include your Google Sheet credentials.
- Use [gsheets:credentials_path:] for a path to your credentials.
- Use [gsheets:credentials:] to paste credentials Json details.

${white("How to get your credentials?", bold: true)}
${cyan("https://github.com/roipeker/flutter_translation_sheet/wiki/Google-credentials", bold: false)}
''');
    exit(2);
  }
  config.sheetId = doc['spreadsheet_id'];
  config.tableId = doc['worksheet'];
  config.useIterativeCache = doc['use_iterative_cache'] ?? false;
}

void setCredentials({String? path, Map? json}) {
  if (json != null) {
    config.sheetCredentials = json;
  } else if (path != null) {
    var credentialsString = openString(path);
    // if (credentialsString.isEmpty) {
    //   error(
    //       "ERROR: [gsheets:credentials_path:$path] doesn\'t exists or is empty.");
    //   exit(2);
    // }
    config.sheetCredentials = credentialsString;
  } else {
    final sysPath = Platform.environment['FTS_CREDENTIALS'];
    if (sysPath != null) {
      // print('spreadsheet id:\n - ' + magenta(config.sheetId!));
      trace(
          'fts detected ${magenta('FTS_CREDENTIALS')} variable in your system environment. Using it.');
      var credentialsString = openString(sysPath);
      config.sheetCredentials = credentialsString;
    }
  }
}

/// Model to represent the configuration (trconfig.yaml).
class EnvConfig {
  // String outputDir = 'output';
  String dartOutputDir = '';

  ///@deprecated
  String outputJsonDir = '';

  bool dartOutputFtsUtils = false;

  String outputJsonTemplate = '';
  String outputArbTemplate = '';

  bool outputAndroidLocales = true;
  String entryFile = '';
  bool resolveLinkedKeys = false;
  String paramFtsUtilsArgsPattern = '%s';
  String paramOutputPattern = '{*}';
  String paramOutputPattern1 = '{{';
  String paramOutputPattern2 = '}}';

  /// @deprecated
  // bool intlEnabled = false;

  /// assigned from [entryFile]
  String inputYamlDir = '';

  // param_output_pattern
  bool useDartMaps = false;

  int dartFormatLineLength = 0;

  String get iosDirPath {
    return p.canonicalize(p.join(configProjectDir, 'ios'));
  }

  String get macosDirPath {
    return p.canonicalize(p.join(configProjectDir, 'macos'));
  }

  String get androidDirPath {
    return p.canonicalize(p.join(configProjectDir, 'android'));
  }

  // String get intlYamlPath {
  //   return !intlEnabled ? '' : joinDir([configProjectDir, 'l10n.yaml']);
  // }

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

  bool isValidCredentials() {
    return sheetCredentials != null &&
        '$sheetCredentials'.toString().isNotEmpty;
  }

  String get dartTKeysClassname {
    return dartTKeysId.pascalCase;
  }

  String get dartTranslationClassname {
    return dartTranslationsId.pascalCase;
  }

  String get dartTranslationPath {
    final filename = '${dartTranslationsId.snakeCase}.dart';
    return joinDir([dartOutputDir, filename]);
  }

  String get dartFtsUtilsPath {
    return joinDir([dartOutputDir, 'utils.dart']);
  }

  String get dartTkeysPath {
    final filename = '${dartTKeysId.snakeCase}.dart';
    return joinDir([dartOutputDir, filename]);
  }

  EnvConfig._();

  bool get validTKeyFile => dartTKeysId.isNotEmpty;

  bool get validTranslationFile => dartTranslationsId.isNotEmpty;

  String get inputVarsFile => joinDir([config.inputYamlDir, '.vars.lock']);

  bool get hasOutputJsonDir => outputJsonDir.isNotEmpty;

  bool get hasOutputArbDir => outputArbTemplate.isNotEmpty;

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

  String arbOutputDir = '';
  String _arbOutputFilename = '';

  String jsonOutputDir = '';
  String _jsonOutputFilename = '';

  void _configOutputTemplates() {
    if (outputJsonTemplate.isNotEmpty) {
      var str = outputJsonTemplate;

      /// json for filename and dir.
      jsonOutputDir = p.canonicalize(p.dirname(str));

      /// todo: override for now, clear later.
      outputJsonDir = jsonOutputDir;
      _jsonOutputFilename = p.basename(str);
      if (_jsonOutputFilename.split('*').length > 2) {
        error(AppStrings.kInvalidOutputJsonTemplate);
        exit(3);
      }
    }

    if (outputArbTemplate.isNotEmpty) {
      var str = outputArbTemplate;

      /// arb for filename and dir.
      arbOutputDir = p.canonicalize(p.dirname(str));
      _arbOutputFilename = p.basename(str);
      if (_arbOutputFilename.split('*').length > 2) {
        error(AppStrings.kInvalidOutputJsonTemplate);
        exit(3);
      }
    }
  }

  String getArbFilePath(String locale) {
    if (hasOutputArbDir) {
      var name = _arbOutputFilename.replaceAll('*', locale);
      name = p.basenameWithoutExtension(name);

      /// force extension...
      name += '.arb';
      return p.join(arbOutputDir, name);
    }
    return '';
  }

  String getJsonFilePath(String locale) {
    if (hasOutputJsonDir) {
      var name = _jsonOutputFilename.replaceAll('*', locale);
      if (!name.contains('.')) {
        name += '.json';
      }
      return p.join(jsonOutputDir, name);
    }
    return '';
  }
}
