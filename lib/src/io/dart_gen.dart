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
  for (var localeKey in localesMap.keys) {
    // trace('Locale ', localeKey);
    var localeName = normLocale(localeKey);
    var localeMap = localesMap[localeKey]!;

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

  /// create root file export for dartOutput dir.
  if (dartExportPaths.isNotEmpty) {
    /// create export file.
    createDartExportFile(dartExportPaths);
  }
}

/// Generates the export file with the TKeys and TData files.
void createDartExportFile(List<String> exportPaths) {
  final dir = config.dartOutputDir;
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

    final _tClassName = config.dartTranslationClassname;
    _translateClassString = '''

abstract class $_tClassName {


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
abstract class $_tClassName {
  
  $_tLocalesCode
  
  ${getCodeMapLocaleKeysToMasterText(_tClassName)}
}''';

  // final _transImportsString = transImports.join('\n');
// $_transImportsString
  var fileContent = '''
// ignore_for_file: lines_longer_than_80_chars
import 'dart:ui';
import 'package:flutter/material.dart';
$_imports

$_translateClassString

$_classAppLocales

$_kLangVoTemplate

/// demo widget
$kSimpleLangPickerWidget

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

String _localeVarName(String key) {
  return key.snakeCase;
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
  final fileContent = _translateKeyClasses.join('\n\n');
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
    var fieldName = k.trim().camelCase;
    // fieldName = fieldName.replaceAll(':', '_');
    fieldName = fieldName.replaceAll(invalidCharsRegExp, '_');
    fieldName = _removeInvalidChars(fieldName);
    final c = fieldName.toLowerCase();
    if (reservedWords.contains(c)) {
      changedWords.add(fieldName);
      fieldName = 't$fieldName';
    }

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

//   final tostrName = className;
//   if (path.isNotEmpty && toString) {
//     classStr += '''
//   @override
//   String toString() => """\\$tostrName:$path''';
//     if (tostrFields.isNotEmpty) {
//       classStr += '\n  -fields: ' + tostrFields.join(', ');
//     }
//     if (tostrKeys.isNotEmpty) {
//       classStr += '\n  -keys: ' + tostrKeys.join(', ');
//     }
//     classStr += '''""";
// ''';
//   }

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

// String _cleanLocaleKey(String key) => key.replaceAll('-', '_').trim();

String _buildLocaleObjFromType(String key) {
  key = normLocale(key);
  final keys = key.split('-');
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
    if (which('dartfmt').found) {
      'dartfmt -w ${config.dartOutputDir}'.start(
        workingDirectory: config.dartOutputDir,
        detached: true,
        runInShell: false,
      );
    }
  }
}

/// Saves [localeName] translation [map] in [EnvConfig.outputJsonDir].
/// With the option to [beautify] the json string output.
void saveLocaleJsonAsset(
  String localeName,
  KeyMap map, {
  bool beautify = false,
}) {
  if (!localeName.endsWith('.json')) {
    localeName += '.json';
  }
  var path = joinDir([config.outputJsonDir, localeName]);
  trace('Saving locale asset "$localeName" in ', path);
  saveJson(path, map, beautify: beautify);
}

final changedWords = <String>[];

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
