import 'package:dcli/dcli.dart';
import 'package:flutter_translation_sheet/flutter_translation_sheet.dart';
import 'package:flutter_translation_sheet/src/samples/samples.dart';
import 'package:path/path.dart' as p;

int _classCounter = 0;
final _translateKeyClasses = [];

/// String template for [LangVo]
const _kLangVoTemplate = '''
class LangVo {
  final String nativeName, englishName, key, flagChar;
  final Locale locale;
  const LangVo(this.nativeName, this.englishName, this.key, this.locale, [this.flagChar='']);
  @override
  String toString() => 'LangVo {nativeName: "\$nativeName", englishName: "\$englishName", locale: \$locale, emoji: this.flagChar}';
}
''';

/// Generates the json and dart files according to [EnvConfig].
void createLocalesFiles(
  Map<String, Map<String, String>> localesMap,
  Map<String, dynamic> masterMap,
) {
  var dartExportPaths = <String>[];
  if (config.validTKeyFile) {
    dartExportPaths.add(config.dartTkeysPath);
    createTKeyFileFromMap(masterMap, save: true, includeToString: true);
  }

  /// collect imports for the output.
  var translateImports = <String>[];
  var translateLines = <String>[];
  var saveJsonLocales = config.hasOutputJsonDir;

  if (saveJsonLocales) {
    trace('Saving json locales in ${config.jsonOutputDir}:');
    addAssetsToPubSpec();
  }

  for (var localeKey in localesMap.keys) {
    // trace('Locale ', localeKey);
    var localeName = normLocale(localeKey);
    var localeMap = localesMap[localeKey]!;
    // trace("Locale map: $localeKey / $localeMap");
    /// save json files.
    if (saveJsonLocales) {
      saveLocaleJsonAsset(
        localeName,
        localeMap,
        beautify: true,
      );
    }

    /// save dart file.
    if (config.useDartMaps && config.validTranslationFile) {
      /// Dart translation file.
      var data = prettyJson(localeMap);

      /// cleanup special chars in translated String.
      data = data.replaceAll(r'$', '\\\$');

      var localeInfo = langInfoFromKey(localeName);
      var className = 'Locale${localeName.pascalCase}';
      var fileData = '''
/// Translation for ${localeInfo.englishName} ("${localeInfo.key.toUpperCase()}")
// ignore_for_file: lines_longer_than_80_chars
abstract class $className {
  static const Map<String,String> data = $data;
}
''';
      var fileName = localeName.toLowerCase().snakeCase + '.dart';
      var filePath = joinDir([config.dartOutputDir, fileName]);
      saveString(filePath, fileData);
      translateImports.add('import "$fileName";');
      translateLines.add('\t\t"$localeName": $className.data,');
    }
  }

  /// create translation and locale file
  if (config.validTranslationFile) {
    createTranslationFile(
      config.locales,
      save: true,
      imports: translateImports,
      translationMaps: translateLines,
    );
    dartExportPaths.add(config.dartTranslationPath);
  }

  if (config.dartOutputFtsUtils) {
    createFtsUtilsFile();
    dartExportPaths.add(config.dartFtsUtilsPath);
  }

  /// create root file export for dartOutput dir.
  if (dartExportPaths.isNotEmpty) {
    /// create export file.
    createDartExportFile(dartExportPaths);
  }
}

void createFtsUtilsFile() {
  var fileContent = kFtsUtils;
  // fileContent = fileContent.replaceAll('##importPath', import);
  fileContent =
      fileContent.replaceAll('##tData', config.dartTranslationClassname);

  var imports = [
    p.basename(config.dartOutputDir) + '.dart',
    "package:flutter/widgets.dart",
    "package:flutter/foundation.dart",
  ];

  if (config.hasOutputJsonDir) {
    imports.addAll([
      "dart:convert",
      "package:flutter/foundation.dart",
      "package:flutter/services.dart",
    ]);

    fileContent =
        fileContent.replaceAll('##loadJsonSetLocale', kLoadJsonSetLocale);
    fileContent =
        fileContent.replaceAll('##loadJsonFallback', kLoadJsonFallback);
    var loadJsonString = kLoadJsonMethod;

    // var jsonOutput = config.outputJsonTemplate;
    var jsonOutputDir = p.dirname(config.outputJsonTemplate) + '/';
    loadJsonString = loadJsonString.replaceAll('##jsonDir', jsonOutputDir);
    fileContent = fileContent.replaceAll('##loadJsonMethod', loadJsonString);

    fileContent = fileContent.replaceAll(
        '##decodeTranslationMethod', kDecodeTranslationMethod);
  } else {
    fileContent =
        fileContent.replaceAll('##loadJsonSetLocale', '_notifyUpdate();');
    fileContent = fileContent.replaceAll('##loadJsonFallback', '');
    fileContent = fileContent.replaceAll('##loadJsonMethod', '');
    fileContent = fileContent.replaceAll('##decodeTranslationMethod', '');
  }

  fileContent = fileContent.replaceFirst(
    '##argsPattern',
    config.paramFtsUtilsArgsPattern,
  );

  var patt = config.paramOutputPattern;
  if (patt.isEmpty || patt == '*') {
    trace("PARAM ISFUCKED! $patt");
    patt = '{*}';
  }
  patt = patt.replaceFirst('*', '\$key');
  fileContent = fileContent.replaceFirst(
    '##namedArgsPattern',
    patt,
  );

  var importString = imports.map((e) => "import '$e';").join('\n');
  fileContent = fileContent.replaceAll('##imports', importString);

  saveString(config.dartFtsUtilsPath, fileContent);

  // trace("Base name? ${}");
  // exportPaths.sort();
  // var fileContents = exportPaths
  //     .map((path) => 'export "${p.relative(path, from: dir)}";')
  //     .join('\n');
  // var exportFilePath = p.join(dir, p.basename(dir) + '.dart');
  // print("EXPORT PATH: $exportFilePath");
}

/// Generates the export file with the TKeys and TData files.
void createDartExportFile(List<String> exportPaths) {
  final dir = config.dartOutputDir;
  exportPaths.sort();
  var fileContents = exportPaths
      .map((path) => 'export "${p.relative(path, from: dir)}";')
      .join('\n');
  var exportFilePath = p.join(dir, p.basename(dir) + '.dart');

  /// export the file.
  saveString(exportFilePath, fileContents);
}

/// Generates the `TData.dart` and the specified [locales] translations as dart
/// files.
String createTranslationFile(
  List<String> locales, {
  required List<String> imports,
  required List<String> translationMaps,
  bool save = true,
}) {
  if (locales.isEmpty) {
    locales.add('en');
  }
  var _classAppLocales = _buildAppLocalesFileContent(locales);
  var hasTranslationMaps = imports.isNotEmpty;
  var _imports = imports.join('\n');
  var _translateClassString = '';

  /// TData file
  final _tClassName = config.dartTranslationClassname;
  var _tLocalesCode = '';

  /// only add locale codes if user asks for useMaps:true
  if (hasTranslationMaps) {
    /// Translation File.
    var _transKeysString = '{\n';
    _transKeysString += translationMaps.join('\n');
    _transKeysString += '  };\n';

    _tLocalesCode = '''
  static Map<String, Map<String, String>> byKeys = getByKeys();
  static Map<String, Map<String, String>> getByKeys() => $_transKeysString
  
  static Map<String, Map<String, String>>? _byText;
  static Map<String, Map<String, String>> get byText {
    _byText ??= getByText();
    return _byText!;
  }
  
  static Map<String, Map<String, String>> getByText() {
    final source = getByKeys();
    final output = <String, Map<String, String>>{};
    final master = source[AppLocales.available.first.key]!;
    for (final localeKey in source.keys) {
      output[localeKey] = mapLocaleKeysToMasterText(
        source[localeKey]!,
        masterMap: master,
      );
    }
    return output;
  }
''';
  } else {
    /// keep the fields for easy map access, if the user wants to cache
    /// the json somewhere.
    _tLocalesCode = '''
  static Map<String, Map<String, String>> byKeys = {};
  static Map<String, Map<String, String>> byText = {};
''';
  }

  _translateClassString = '''
//ignore: avoid_classes_with_only_static_members
abstract class $_tClassName {
  
  $_tLocalesCode
  
  ${getCodeMapLocaleKeysToMasterText(_tClassName)}
}''';

  // final _transImportsString = transImports.join('\n');
// $_transImportsString
  var fileContent = '''
// ignore_for_file: lines_longer_than_80_chars
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
$_imports

$_translateClassString

$_classAppLocales

$_kLangVoTemplate

/// demo widgets

$kLangPickerMaterial

$kLangPickerCupertino

''';
  if (save) {
    var filepath = config.dartTranslationPath;
    // trace('Building translations ($className) file at ', filepath);
    saveString(filepath, fileContent);
  }
  return fileContent;
}

String _buildAppLocalesFileContent(List<String> locales) {
  var fileContent = '''
//ignore: avoid_classes_with_only_static_members
abstract class AppLocales {
''';
  final _fields = locales.map((String key) {
    // key = _cleanLocaleKey(key);
    key = normLocale(key);
    var localName = _localeVarName(key);
    // var data = prettyJson(localeMap);
    // var localeInfo = langInfoFromKey(localeName);
    // var className = 'Locale${localeName.pascalCase}';

    final langObj = langInfoFromKey(key);
    final nativeName = langObj.nativeName;
    final englishName = langObj.englishName;
    final flagChar = langObj.emoji;
    final locale = _buildLocaleObjFromType(key);
    return '''
  static const $localName = LangVo("$nativeName", "$englishName", "$localName", $locale, "$flagChar");''';
  }).join('\n');

  fileContent += _fields + '\n';

  final _supportedLocales =
      locales.map((String key) => '${_localeVarName(key)}\.locale').join(',');
  final _availableLang =
      locales.map((String key) => '${_localeVarName(key)}').join(',');

  fileContent += '  static const available = <LangVo>[$_availableLang];\n';
  fileContent +=
      '  static List<Locale> get supportedLocales => [$_supportedLocales];\n';
  // '  static List<Locale> get supportedLocales => _supportedLocales;\n';
  // fileContent +=
  //     '  static final _supportedLocales = <Locale>[$_supportedLocales];\n';
  fileContent += '''
  static Locale get systemLocale => window.locale;
  static List<Locale> get systemLocales => window.locales;
''';

  fileContent += '''
  static LangVo? of(Locale locale, [bool fullMatch = false]) {
    for (final langVo in AppLocales.available) {
      if ((!fullMatch && langVo.locale.languageCode == locale.languageCode) ||
          langVo.locale == locale) {
        return langVo;
      }
    }
    return null;
  }  
''';

  fileContent += '}';

  return fileContent;
}

/// Normalize locale [key] to match Flutter's.
String _localeVarName(String key) {
  return key.replaceAll('-', '_');
}

/// Generates the TKeys file from the [map].
String createTKeyFileFromMap(
  JsonMap map, {
  bool save = false,
  bool includeToString = true,
}) {
  var className = config.dartTKeysClassname; //'TKeys'
  changedWords.clear();
  _buildTKeyMap(
    map: map,
    key: className,
    path: '',
    toString: includeToString,
  );
  if (changedWords.isNotEmpty) {
    print(
      'These following keys have been changed with a prefix ${cyan("t + key")} because they are reserved words:',
    );
    changedWords.forEach((e) => print('- $e > t$e'));
  }
  final fileContent =
      '// ignore_for_file: lines_longer_than_80_chars\n\n ${_translateKeyClasses.join('\n\n')}';

  _translateKeyClasses.clear();
  if (save) {
    var filepath = config.dartTkeysPath;
    // var filepath = joinDir([config.outputDir, 'i18n/tkeys.dart']);
    trace('🧱 Building keys file ($className)\n - $filepath:');
    saveString(filepath, fileContent);
  }
  return fileContent;
  // trace('saving i18n keys');
  // saveString('i18n/tkeys.dart', fileContent);
}

String createTKeyFileFromPath(String masterFile, {bool save = false}) {
  final map = openJson(masterFile);
  _classCounter = 1;
  return createTKeyFileFromMap(KeyMap.from(map), save: save);
}

final invalidCharsRegExp = RegExp(
  r'[^\w\.@]',
  caseSensitive: false,
  dotAll: true,
  unicode: false,
);

final onlyDigitRegExp = RegExp(r'\d');

/// TKeys Map generation.
String _buildTKeyMap({
  required JsonMap map,
  required String key,
  required String path,
  bool toString = true,
}) {
  late String className;
  var isRoot = path.isEmpty;
  if (!isRoot) {
    path += '.';
    className = getClassName(key);
    className = '\$$className';
  } else {
    className = key.trim().pascalCase;
  }
  final fields = <String>[];
  final tostrKeys = <String>[];
  final tostrFields = <String>[];
  var classStr = 'class $className {\n';
  // final invalidCharsRegExp = ':';

  var classCanBeConst = false;

  for (var k in map.keys) {
    final v = map[k];

    /// special case for @properties n .arb (invalid for dart files)
    if (k.startsWith('@')) {
      trace('... skipping property $k from Keys');
      continue;
    }

    /// TODO: find bad characters for the field...
    var fieldName = k.trim();
    // fieldName = fieldName.replaceAll(':', '_');
    fieldName = fieldName.replaceAll(invalidCharsRegExp, '_');
    fieldName = _removeInvalidChars(fieldName);

    /// adjust variable to not be private.
    if (fieldName.startsWith('_')) {
      fieldName = fieldName.substring(1);
    }
    final c = fieldName.toLowerCase();

    /// check for reserved key words or if we are left with a digit only field
    /// name.
    if (reservedWords.contains(c) || c.startsWith(onlyDigitRegExp)) {
      changedWords.add(fieldName);
      fieldName = 't$fieldName';
    }
    fieldName = fieldName.camelCase;
    var localPath = path + k;
    String _fieldModifier;

    /// no constants.
    // _fieldModifier = 'static const';
    if (isRoot) {
      _fieldModifier = 'static';
    } else {
      _fieldModifier = 'final';
    }

    /// fields
    // print('key: $k - ${v.runtimeType}');
    if (v is String) {
      tostrKeys.add('$fieldName');
      classCanBeConst = false;
      fields.add('$_fieldModifier String $fieldName = \'$localPath\';');
    } else {
      if (v is Map) {
        final fieldType = _buildTKeyMap(
          map: v.cast(),
          key: k,
          path: localPath,
          toString: toString,
        );
        tostrFields.add('$fieldName');
        final _modifier = isRoot || !classCanBeConst ? '' : ' const';
        fields.add(
            '$_fieldModifier $fieldType $fieldName = $_modifier $fieldType._();');
      }
    }
  }

  if (path.isNotEmpty && toString) {
    classStr += '''
  @override
  String toString() => "$path";

''';
  }

  /// private constructor.
  var classModifier = classCanBeConst ? 'const ' : '';
  classStr += ' $classModifier$className._();\n';
  for (var line in fields) {
    classStr += '  $line\n';
  }
  classStr += '}';
  _translateKeyClasses.add(classStr);
  return className;
}

final _invalidClassNamesRegExp = RegExp('@|#|\$|:');

String _removeInvalidChars(String name) {
  return name.replaceAll(_invalidClassNamesRegExp, '');
}

String getClassName(String name) {
  ++_classCounter;

  /// remove invalid chars.
  name = _removeInvalidChars(name);
  name = '${name.trim()}$_classCounter'.pascalCase;
  return name;
}

String _buildLocaleObjFromType(String key) {
  key = normLocale(key, '_');
  final keys = key.split('_');
  if (keys.length == 1) {
    return 'Locale("${keys[0]}")';
  }
  return 'Locale("${keys[0]}","${keys[1]}")';
}

void runPubGet() {
  if (which('flutter').found) {
    var canoDir = configProjectDir;
    trace('run pub get!', canoDir);
    sleep(2);
    'flutter pub get $canoDir'.start(
      detached: false,
    );
  }
}

/// Format the selected dart folder with `dartfmt` if available.
void formatDartFiles() {
  /// format dart files.
  if (config.validTranslationFile || config.validTKeyFile) {
    if (which('flutter').found) {
      // 'dartfmt -w ${config.dartOutputDir}'.start(
      'flutter format --fix ${config.dartOutputDir}'.start(
        // workingDirectory: config.dartOutputDir,
        detached: true,
        runInShell: false,
      );
    }
  }
}

void flutterHotReload() {
  if (which('flutter').found) {
    trace('Running `flutter pub get`...');
    'flutter pub get'.start(
      workingDirectory: configProjectDir,
      detached: true,
      runInShell: true,
    );
  }
}

/// Saves [localeName] translation [map] in [EnvConfig.outputJsonDir].
/// With the option to [beautify] the json string output.
void saveLocaleJsonAsset(
  String localeName,
  KeyMap map, {
  bool beautify = false,
}) {
  /// not valid anymore.
  // if (!localeName.endsWith('.json')) {
  //   localeName += '.json';
  // }
  // var path = joinDir([config.outputJsonDir, localeName]);
  var path = config.getJsonFilePath(localeName);
  // trace('Saving json "$localeName" in ', path);
  saveJson(path, map, beautify: beautify);
}

/// List of modified words captured based on [reservedWords].
final changedWords = <String>[];

/// List of Dart reserved words to be escaped in the TKeys output.
final reservedWords = [
  'abstract',
  'else',
  'import',
  'show',
  'as',
  'enum',
  'in',
  'static',
  'assert',
  'export',
  'interface',
  'super',
  'async',
  'extends',
  'is',
  'switch',
  'await',
  'extension',
  'late',
  'sync',
  'break',
  'external',
  'library',
  'this',
  'case',
  'factory',
  'mixin',
  'throw',
  'catch',
  'false',
  'new',
  'true',
  'class',
  'final',
  'null',
  'try',
  'const',
  'finally',
  'on',
  'typedef',
  'continue',
  'for',
  'operator',
  'var',
  'covariant',
  'function',
  'part',
  'void',
  'default',
  'get',
  'required',
  'while',
  'deferred',
  'hide',
  'rethrow',
  'with',
  'do',
  'if',
  'return',
  'yield',
  'dynamic',
  'implements',
  'set',
];
