import 'dart:io' as io;

import 'package:trcli/translate_cli.dart';
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
      var val = inner[k];
      var p2 = prop.isEmpty ? k : prop + '.' + k;
      if (val is Map) {
        buildKeys(val, p2);
      } else {
        output[p2] = inner[k];
      }
    }
  }

  buildKeys(content, '');
  // hashMap.forEach((key, value) {
  //   print('$key : $value');
  // });

  return output;
}
