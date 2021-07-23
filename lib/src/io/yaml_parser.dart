import 'dart:io' as io;

import 'package:flutter_translation_sheet/flutter_translation_sheet.dart';
import 'package:yaml/yaml.dart';

const kRef = '\$ref';
const kUnwrap = '\$unwrap';

JsonMap buildLocalYamlMap() {
  var entryFile = config.entryFile;
  var parseMap = {};
  _addDoc(entryFile, parseMap);
  trace('document generated...');
  return JsonMap.from(parseMap);
  // return _canoMap(parseMap);
}

KeyMap buildCanoMap(Map map) {
  return _canoMap(map);
}

String openYaml(String path) {
  if (!path.endsWith('.yaml')) {
    path += '.yaml';
  }
  if (!path.startsWith(config.inputYamlDir)) {
    path = config.inputYamlDir + path;
  }
  // if (!path.startsWith('data/')) {
  //   path = 'data/master/$path';
  // }
  return openString(path);
}

void _addDoc(String path, Map into) {
  var parentDir = io.File(path).parent.path;
  var string = openYaml(path);
  if (string.isEmpty) {
    print('Yaml file "$path" is empty or doesnt exists.');
  } else {
    var doc = loadYaml(string);
    if (doc is YamlMap) {
      _copyDoc(doc, parentDir, into);
    } else {
      print('Yaml unsupported format');
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
        _addDoc(dir2, target);
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

KeyMap _canoMap(Map content) {
  final output = <String, String>{};
  void buildKeys(Map inner, String prop) {
    for (var k in inner.keys) {
      if (inner[k] == null) {
        trace('"$k" has a null value');
      }
      var val = inner[k];
      var p2 = prop.isEmpty ? k : prop + '.' + k;
      if (val is Map) {
        buildKeys(val, p2);
      } else {
        output[p2] = val ?? ' ';
      }
    }
  }

  buildKeys(content, '');
  // hashMap.forEach((key, value) {
  //   print('$key : $value');
  // });

  return output;
}

// final _matchParamsRegExp1 = RegExp(r'(?<=\{\{)(.+?)(?=\}\})');
final _matchParamsRegExp2 = RegExp(r'\{\{(.+?)\}\}');
// final _matchParamsRegExp2 = RegExp(r'\{(.+?)\}');

class VarsCap {
  final Map<String, String> vars;
  final String text;

  VarsCap(this.text, this.vars);
}

void putVarsInMap(Map<String, Map<String, String>> map) {
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
  for (var localeKey in map.keys) {
    final localeMap = map[localeKey]!;
    for (var key in localeMap.keys) {
      if (varsMap.containsKey(key)) {
        var text = localeMap[key]!;
        localeMap[key] = replaceVars(VarsCap(text, varsMap[key]!));
      }
    }
  }
}

void buildVarsInMap(Map<String, String> map) {
  var varsKeys = <String, Map<String, String>>{};
  for (var key in map.keys) {
    var val = map[key]!;
    // trace(key, ': ', );
    if (val.contains('{{')) {
      var res = captureVars(val);
      if (res.vars.isNotEmpty) {
        varsKeys[key] = res.vars;

        /// replace contents of file for upload.
        map[key] = res.text;
      }
    }
  }

  if (varsKeys.isNotEmpty) {
    var varsContent = json2yaml(varsKeys, yamlStyle: YamlStyle.pubspecYaml);
    saveString(config.inputVarsFile, varsContent);
    trace(
        'Found ${varsKeys.keys.length} keys with variables, saved at ${config.inputVarsFile}');
  } else {
    /// clear file ?
  }
}

String replaceVars(VarsCap vars) {
  var str = vars.text;
  var start = config.paramOutputPattern1;
  var end = config.paramOutputPattern2;
  if (_matchParamsRegExp2.hasMatch(str)) {
    final wordset = <String>{};
    final matches = _matchParamsRegExp2.allMatches(str);
    for (var match in matches) {
      wordset.add(str.substring(match.start, match.end));
    }
    // Replacing
    var words = wordset.toList();
    for (var i = 0; i < words.length; i++) {
      var _key = words[i];
      var key = _key.substring(2, _key.length - 2);
      var value = vars.vars[key];
      str = str.replaceAll(_key, '$start$value$end');
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
      out[key] = value.substring(2, value.length - 2);
      str = str.replaceAll(value, '{{$key}}');
    }
  }
  return VarsCap(str, out);
}
