import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:flutter_translation_sheet/flutter_translation_sheet.dart';
import 'package:path/path.dart' as p;

String libFolder = '';
String extractStringOutputFile = '';
bool extractPermissive = false;
String extractAllowedExtensions = 'dart';
String extractExcludePaths = '';
bool extractCleanResults = false;

/// Logic for `fts extract`
Future<void> extractStrings() async {
  if (libFolder.isEmpty) {
    libFolder = p.absolute('.');
  }
  // trace("Extracting permissive: ", extractPermissive, ' files:',
  //     extractAllowedExtensions);
  libFolder = p.canonicalize(libFolder);
  if (!p.split(libFolder).contains('lib')) {
    trace('''WARNING: fts is not finding /lib in the current search path. 
As it uses brute-force approach for String matching and file access, if the program takes much time,
cancel the operation and pass --path argument to run a faster analysis.
Or change the current working directory to /lib or some sub-folder. 
''');
  }
  if (!exists(libFolder)) {
    error(
        'Folder $libFolder doesn\'t exists. Please select a valid /lib folder to extract Strings.');
    exit(3);
  }
  if (extractStringOutputFile.isEmpty) {
    error('Please set the --output parameter to save strings.json');
    exit(3);
  }
  _inspectRecursive(libFolder);
}

/// Reads [path] recursively capturing the Strings in matched files.
void _inspectRecursive(String path) {
  trace('Looking for strings in ', path);
  var dir = Directory(path);
  var allowedExtensions = extractAllowedExtensions.split(',').map((e) {
    var ext = e.trim();
    if (!ext.startsWith('.')) {
      return '.$ext';
    }
    return ext;
  }).toList(growable: false);

  trace('Accepting extensions: ', allowedExtensions.join(', '));
  if (extractPermissive) {
    trace('Running in permissive move, strings without spaces are captured');
  }
  var allFileEntities = dir.listSync(recursive: true);

  var excludePathsList = [];
  extractExcludePaths = extractExcludePaths.trim();
  if (extractExcludePaths.isNotEmpty) {
    excludePathsList = extractExcludePaths
        .split(',')
        .map((e) => e.trim())
        .toList(growable: false);
  }
  final hasExcludePaths = excludePathsList.isNotEmpty;
  final files = allFileEntities
      .where((e) {
        if (hasExcludePaths) {
          for (final p in excludePathsList) {
            if (e.path.contains(p)) {
              return false;
            }
          }
        }
        if (e is File) {
          if (p.basename(e.path).startsWith('.')) {
            return false;
          }
          var ext = p.extension(e.path, 1);
          return allowedExtensions.contains(ext);
        }
        return false;
      })
      .toList(growable: false)
      .cast<File>();

  trace('Inspecting ${files.length} files');
  var uniqueTextCollection = <String>[];
  var duplicatesCount = 0;
  final canoMap = <String, String>{};
  for (final f in files) {
    var populatorSub = <String>[];
    _takeFile(f, populatorSub);
    if (populatorSub.isNotEmpty) {
      var key = _getKey(f.path);
      var j = 0;
      for (var i = 0; i < populatorSub.length; ++i) {
        var val = populatorSub[i];
        if (extractCleanResults) {
          if (!uniqueTextCollection.contains(val)) {
            uniqueTextCollection.add(val);
          } else {
            ++duplicatesCount;
            continue;
          }
        }
        val = val.replaceAll('"', '\\"');
        val = val.replaceAll('\\{{', '{{');
        if (num.tryParse(val) != null) {
          continue;
        }

        /// skip only var text.
        if (val.startsWith('{{') &&
            val.endsWith('}}') &&
            val.lastIndexOf('{{') == 0) {
          continue;
        }

        /// skip whatever has no grapheme character in any text (like $21.99, --** #$!@ etc)
        if (!_anyKindOfLetterRegExp.hasMatch(val)) {
          // print("skip $val");
          continue;
        }

        var key0 = '${key}text${j + 1}';
        ++j;
        canoMap[key0] = val;
      }
    }
  }
  if (extractCleanResults) {
    trace('Skipped $duplicatesCount duplicates.');
  }

  /// create keys.
  var jsonMap = <String, dynamic>{};
  void buildInnerMap(
      List<String> levels, Map<String, dynamic> parent, String finalValue) {
    var lvl = levels.removeAt(0);
    parent[lvl] ??= <String, dynamic>{};
    if (levels.isNotEmpty) {
      buildInnerMap(levels, parent[lvl], finalValue);
    } else {
      parent[lvl] = finalValue;
    }
  }

  for (var k in canoMap.keys) {
    var parts = k.split('.');
    buildInnerMap(parts, jsonMap, canoMap[k]!);
  }

  trace('We found ${canoMap.keys.length} strings in $libFolder');
  var finalPath = extractStringOutputFile;
  var ext = p.extension(finalPath);
  var isJson = ext == '.json';
  if (!isJson && ext != '.yaml') {
    isJson = true;
    finalPath += '.json';
  }
  var contentString = '';
  if (isJson) {
    contentString = prettyJson(jsonMap);
  } else {
    contentString = json2yaml(jsonMap, yamlStyle: YamlStyle.generic);
  }
  saveString(finalPath, contentString);
  trace('Extracted strings saved in $finalPath');
}

/// Makes a "key" based on [filepath].
String _getKey(String filepath) {
  /// all path (keys) relative to the -p (libFolder)
  var sub = p.relative(filepath, from: libFolder);
  sub = '${p.withoutExtension(sub)}.';
  return p.split(sub).join('.');
}

var _regex4 = RegExp("'.*?'|\".*?\"", dotAll: false);
var _regexMultiline = RegExp("('''.+''')|(\"\"\".+\"\"\")", dotAll: true);
var _regexR1 = RegExp(r'(import|export) .*?;');
var _pathRegExp = RegExp('(/|.*/)');
final varMatching = RegExp(
  r'\$([^ ]*)',
  caseSensitive: false,
  dotAll: true,
  multiLine: true,
);
final varReplacer = RegExp(r'[\$|\{\}]');

/// matches any charset, but only graphemes (glyphs) are captured.
final _anyKindOfLetterRegExp =
    RegExp(r'\p{L}', unicode: true, dotAll: true, caseSensitive: false);

/// Reads [file] from the extraction recursion, using [populate] List to store
/// the matching Strings.
void _takeFile(File file, List<String> populate) {
  var str = file.readAsStringSync();
  str = str.replaceAll(_regexR1, '');
  var hasEscaped1 = str.contains("\\'");
  var hasEscaped2 = str.contains('\\"');

  if (hasEscaped1) {
    str = str.replaceAll("\\'", '*^%#');
  }
  if (hasEscaped2) {
    str = str.replaceAll('\\"', '#%^*');
  }

  var fusion = _regex4.allMatches(str);
  var fusion2 = _regexMultiline.allMatches(str);

  for (var m in fusion2) {
    var str = m.group(0)!;
    str = str.substring(3, str.length - 3);
    str = str.trim();
    var hasSpace = extractPermissive || str.contains(' ');
    if (str.isNotEmpty && hasSpace && !str.contains(_pathRegExp)) {
      if (hasEscaped1) {
        str = str.replaceAll('*^%#', "'");
      }
      if (hasEscaped2) {
        str = str.replaceAll('#%^*', '"');
      }
      str = _replaceVarsInString(str);
      if (str.isNotEmpty) {
        populate.add(str);
      }
    }
  }

  for (var m in fusion) {
    var str = m.group(0)!;
    str = str.substring(1, str.length - 1);
    str = str.trim();
    var hasSpace = extractPermissive || str.contains(' ');
    if (str.isNotEmpty && hasSpace && !str.contains(_pathRegExp)) {
      if (hasEscaped1) {
        str = str.replaceAll('*^%#', "'");
      }
      if (hasEscaped2) {
        str = str.replaceAll('#%^*', '"');
      }
      str = _replaceVarsInString(str);
      if (str.isNotEmpty) {
        populate.add(str);
      }
    }
  }
}

/// Captures the dart string interpolations inside the string, and convert
/// them to fts placeholders
String _replaceVarsInString(String str) {
  if (!varMatching.hasMatch(str)) {
    return str;
  }
  var captures = varMatching.allMatches(str);
  for (var element in captures) {
    var capturedString = element.group(0)!;
    var varName = capturedString.replaceAll(varReplacer, '');

    /// take the last element.
    varName = varName.split('.').last.camelCase;
    str = str.replaceAll(capturedString, '{{$varName}}');

    /// optimization, skip text if its only a variable.
    if (captures.length == 1) {
      if (str == '{{$varName}}') {
        return '';
      }
    }
  }
  return str;
}
