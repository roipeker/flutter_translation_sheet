import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:flutter_translation_sheet/flutter_translation_sheet.dart';
import 'package:flutter_translation_sheet/src/utils/json2yaml.dart';
import 'package:path/path.dart' as p;

String libFolder = '';
String extractStringOutputFile = '';
bool extractPermissive = false;
String extractAllowedExtensions = 'dart';

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
    if (!ext.startsWith('.')) return '.$ext';
    return ext;
  }).toList(growable: false);
  trace('Accepting extensions: ', allowedExtensions.join(', '));
  if (extractPermissive) {
    trace('Running in permissive move, strings without spaces are captured');
  }
  var allFileEntities = dir.listSync(recursive: true);
  final files = allFileEntities
      .where((e) {
        if (e is File) {
          var ext = p.extension(e.path, 1);
          return allowedExtensions.contains(ext);
        }
        return false;
      })
      .toList(growable: false)
      .cast<File>();

  trace('Inspecting ${files.length} files');

  final canoMap = <String, String>{};
  for (final f in files) {
    var populatorSub = <String>[];
    _takeFile(f, populatorSub);
    if (populatorSub.isNotEmpty) {
      var key = _getKey(f.path);
      for (var i = 0; i < populatorSub.length; ++i) {
        var _key = key + 'text${i + 1}';
        canoMap[_key] = populatorSub[i];
      }
    }
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
    contentString = json2yaml(jsonMap, yamlStyle: YamlStyle.pubspecYaml);
  }
  saveString(finalPath, contentString);
  trace('Extracted strings saved in $finalPath');
}

/// Makes a "key" based on [filepath].
String _getKey(String filepath) {
  /// all path (keys) relative to the -p (libFolder)
  var sub = p.relative(filepath, from: libFolder);
  sub = p.withoutExtension(sub) + '.';
  return p.split(sub).join('.');
}

var _regex4 = RegExp("\'.*?\'|\".*?\"", dotAll: false);
var _regexMultiline = RegExp("('''.+''')|(\"\"\".+\"\"\")", dotAll: true);
var _regexR1 = RegExp(r'(import|export) .*?;');
var _pathRegExp = RegExp('(\/|.*\/)');
final varMatching = RegExp(
  r'\$([^ ]*)',
  caseSensitive: false,
  dotAll: true,
  multiLine: true,
);
final varReplacer = RegExp(r'[\$|\{\}]');

/// Reads [file] from the extraction recursion, using [populate] List to store
/// the matching Strings.
void _takeFile(File file, List<String> populate) {
  var str = file.readAsStringSync();
  str = str.replaceAll(_regexR1, '');
  var fusion = _regex4.allMatches(str);
  var fusion2 = _regexMultiline.allMatches(str);

  for (var m in fusion2) {
    var str = m.group(0)!;
    str = str.substring(3, str.length - 3);
    str = str.trim();
    var hasSpace = extractPermissive || str.contains(' ');
    if (str.isNotEmpty && hasSpace && !str.contains(_pathRegExp)) {
      str = _replaceVarsInString(str);
      populate.add(str);
    }
  }

  for (var m in fusion) {
    var str = m.group(0)!;
    str = str.substring(1, str.length - 1);
    str = str.trim();
    var hasSpace = extractPermissive || str.contains(' ');
    if (str.isNotEmpty && hasSpace && !str.contains(_pathRegExp)) {
      str = _replaceVarsInString(str);
      populate.add(str);
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
  captures.forEach((element) {
    var capturedString = element.group(0)!;
    var varName = capturedString.replaceAll(varReplacer, '');

    /// take the last element.
    varName = varName.split('.').last.camelCase;
    str = str.replaceAll(capturedString, '{{$varName}}');
  });
  return str;
}
