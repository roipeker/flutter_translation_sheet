import 'dart:io';

import 'package:flutter_translation_sheet/flutter_translation_sheet.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

const kRef = '\$ref';
const kUnwrap = '\$unwrap';

JsonMap buildLocalYamlMap() {
  var entryFile = config.entryFile;
  trace('Loading entry_file:\n - $entryFile:');
  var parseMap = {};
  _addDoc(entryFile, parseMap);
  return JsonMap.from(parseMap);
  // return _canoMap(parseMap);
}

KeyMap buildCanoMap(Map<String, dynamic> map) {
  return _canoMap(map.cast());
}

String openYaml(String path) {
  if (!path.endsWith('.yaml')) {
    path += '.yaml';
  }
  if (!path.startsWith(config.inputYamlDir)) {
    /// resolve relative url
    path = config.inputYamlDir + path;
  }
  // if (!path.startsWith('data/')) {
  //   path = 'data/master/$path';
  // }
  return openString(path);
}

void _addDoc(String path, Map into) {
  // var parentDir = io.File(path).parent.path;
  var parentDir = p.dirname(path);
  var string = openYaml(path);
  if (string.isEmpty) {
    print('Yaml file "$path" is empty or doesn\'t exists.');
  } else {
    var doc = loadYaml(string);
    if (doc is YamlMap) {
      _copyDoc(doc, parentDir, into);
    } else {
      print('Can not be parsed as yaml');
    }
  }
}

void _copyDoc(YamlMap doc, String dir, Map into) {
  var unwrapMode = false;
  for (var k in doc.keys) {
    var value = doc[k];
    if (value is YamlMap) {
      // print('here is: $k // ${value.keys} // $unwrapMode');
      Map target;
      if (!unwrapMode) {
        target = into[k] = {};
      } else {
        target = into;
      }

      if (value.containsKey(kRef)) {
        var dir2 = joinDir([dir, value[kRef]]);

        /// special case to unwrap plain text files.
        final ext = p.extension(dir2);
        const plainTextExtensions = ['.txt', '.html', '.htm', '.xhtml', '.md'];
        // if (ext == '.txt' || p.extension(dir2) == '.html') {
        if (plainTextExtensions.contains(ext)) {
          var string = openString(dir2);
          if (string.isNotEmpty) {
            into[k] = string;
          } else {
            error('file reference "$dir2" is empty');
          }
        } else {
          _addDoc(dir2, target);
        }
      } else {
        _copyDoc(value, dir, target);
      }
    } else {
      if (k == kRef) {
        var dir2 = joinDir([dir, value]);
        _addDoc(dir2, into);
        // print('Key is: $k /// ${into.keys}');
      } else {
        if (k == kUnwrap) {
          unwrapMode = value;
        } else {
          // print('$k, $value $unwrapMode');
          into[k] = value;
        }
      }
    }
  }
}

Map<String, dynamic> metaProperties = {};

KeyMap _canoMap(Map<String, dynamic> content) {
  final output = <String, String>{};

  void buildKeys(Map<String, dynamic> inner, String prop) {
    for (var k in inner.keys) {
      if (k.startsWith('@')) {
        /// build meta key, for ARB files.
        var metaKey = '@${('$prop.${k.substring(1)}').camelCase}';
        metaProperties[metaKey] = inner[k];
        trace('found metadata $k skip');
        continue;
      }
      if (inner[k] == null) {
        trace('"$k" has a null value');
      }
      var val = inner[k];
      var p2 = prop.isEmpty ? k : '$prop.$k';
      if (val is Map) {
        buildKeys(val.cast(), p2);
      } else {
        output[p2] = val?.toString() ?? ' ';
      }
    }
  }

  buildKeys(content, '');
  // hashMap.forEach((key, value) {
  //   print('$key : $value');
  // });

  return output;
}

class VarsCap {
  final Map<String, String> vars;
  final String text;

  VarsCap(this.text, this.vars);
}

void putVarsInMap(Map<String, Map<String, String>> map) {
  if (!entryDataHasVars) {
    trace('No placeholders detected.');
    return;
  }
  var varsContent = openString(config.inputVarsFile);
  if (varsContent.trim().isEmpty) return;
  var varsYaml = loadYaml(varsContent);
  if (varsYaml is! YamlMap) return;
  //// convert to regular map.
  final varsMap = <String, Map<String, String>>{};
  varsYaml.forEach((key, value) {
    varsMap['$key'] =
        Map.from(value).map((key, value) => MapEntry('$key', '$value'));
  });
  var linkedKeys = [];
  for (var localeKey in map.keys) {
    final localeMap = map[localeKey]!;
    for (var key in localeMap.keys) {
      if (varsMap.containsKey(key)) {
        var text = localeMap[key]!;
        text = replaceVars(VarsCap(text, varsMap[key]!));
        varsByKeys[key] = varsMap[key];
        if (config.resolveLinkedKeys && text.contains('@:')) {
          linkedKeys.add(key);
        }
        localeMap[key] = text;
      }
    }

    if (config.resolveLinkedKeys && linkedKeys.isNotEmpty) {
      for (var key in linkedKeys) {
        var text = localeMap[key]!;
        RegExp(r'@:(.*?)#').allMatches(text).forEach((match) {
          final toReplace = match.group(0)!;
          var findKey = match.group(1)!;
          if (!localeMap.containsKey(findKey)) {
            error(
                'Can\'t find linked key "$findKey" to replace, make sure is correct.');
            exit(3);
          }
          text = text.replaceAll(toReplace, localeMap[findKey]!);
        });
        localeMap[key] = text;
      }
    }
  }
}

void buildVarsInMap(Map<String, String> map) {
  var varsKeys = <String, Map<String, String>>{};
  for (var key in map.keys) {
    var val = map[key]!;
    if (val.contains('{{')) {
      var res = captureVars(val);
      if (res.vars.isNotEmpty) {
        varsKeys[key] = res.vars;

        /// replace contents of file for upload.
        map[key] = res.text;
      }
    }
  }
  entryDataHasVars = varsKeys.isNotEmpty;
  if (entryDataHasVars) {
    var varsContent = json2yaml(
      varsKeys,
      yamlStyle: YamlStyle.generic,
    );
//     trace('Vars content: ', varsContent);

    saveString(config.inputVarsFile, varsContent);
    trace(
        'Found ${varsKeys.keys.length} key(s) with placeholders.\n - ${config.inputVarsFile}:');
  }
}

// final _matchParamsRegExp1 = RegExp(r'(?<=\{\{)(.+?)(?=\}\})');
final _matchParamsRegExp2 = RegExp(r'\{\{(.+?)\}\}');
// final _matchParamsRegExp2 = RegExp(r'\{(.+?)\}');
final _captureGoogleTranslateVar = RegExp(
  r'({+)(\d{1,3})(}+)',
  multiLine: false,
  caseSensitive: false,
);
// final _captureInnerDigitVar = RegExp(
//   r'\d+',
//   multiLine: false,
//   caseSensitive: false,
// );
final _replaceAndLeaveDigitVar = RegExp(
  r'({+)|(}+)',
  multiLine: false,
  caseSensitive: false,
);

String replaceVars(VarsCap vars) {
  var str = vars.text;
  var start = config.paramOutputPattern1;
  var end = config.paramOutputPattern2;
  if (_captureGoogleTranslateVar.hasMatch(str)) {
    final wordset = <String>{};
    final matches = _captureGoogleTranslateVar.allMatches(str);
    for (var match in matches) {
      wordset.add(str.substring(match.start, match.end));
    }
    // Replacing
    var words = wordset.toList();
    for (var i = 0; i < words.length; i++) {
      var key0 = words[i];
      var key = key0.replaceAll(_replaceAndLeaveDigitVar, '');
      var value = vars.vars[key]!;
      if (value.startsWith('@:')) {
        /// If we resolve linked keys we play safe with the key.
        if (config.resolveLinkedKeys) {
          str = str.replaceAll(key0, '$value#');
        } else {
          str = str.replaceAll(key0, value);
        }
      } else {
        //// special characters taken in account?
        // value = value.replaceAll(r'$', '\\\$');
        str = str.replaceAll(key0, '$start$value$end');
      }
    }
  }
  return str;
}

VarsCap captureVars(String str) {
  var out = <String, String>{};
  if (_matchParamsRegExp2.hasMatch(str)) {
    final wordset = <String>{};
    final matches = _matchParamsRegExp2.allMatches(str);
    for (var match in matches) {
      wordset.add(str.substring(match.start, match.end));
    }
    // Replacing
    var words = wordset.toList();
    for (var i = 0; i < words.length; i++) {
      var key = '$i';
      var value = words[i];
      var innerKey = value.substring(2, value.length - 2);
      innerKey = innerKey.replaceAll('"', '\\"');
      out[key] = innerKey;
      // trace('damn var is:: ${out[key]}');
      str = str.replaceAll(value, '{{$key}}');
    }
  }
  return VarsCap(str, out);
}
