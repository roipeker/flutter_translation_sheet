import 'package:dcli/dcli.dart';
import 'package:yaml/yaml.dart';

import '../../flutter_translation_sheet.dart';

void buildArb(Map<String, Map<String, String>> map) {
  trace('Building arb files');
  var appName = '';
  // detect if we have a l10n.yaml file.
  var arbDir = _getArbDir();
  if(arbDir.isEmpty){
    error('''ERROR: $defaultConfigEnvPath, intl package support is enabled [intl:enabled:true]
But 'arb-dir:' is not define or l10.yaml not found in your target project.
Please make sure your trconfig.yaml sits in the root of your project, and l10n.yaml as well.''');
  }
  for (var localeKey in map.keys) {
    final output = <String, dynamic>{
      '@@last_modified': DateTime.now().toIso8601String(),
      '@@locale': localeKey,
      if (appName.isNotEmpty) 'appName': '$appName',
    };
    var localeMap = map[localeKey]!;
    // make arb file.
    for (var k in localeMap.keys) {
      var newKey = k.camelCase;
      var textValue = localeMap[k]!;
      output[newKey] = textValue;

      /// add description always.
      var placeholders = <String, dynamic>{};
      output['@$newKey'] = {
        // 'type': 'text',
        'placeholders': placeholders,
      };

      if (textValue.contains('{') && textValue.contains('}')) {
        /// get properties back!
        var res = _captureArbSet(textValue);
        if (res.isNotEmpty) {
          res.forEach((e) {
            placeholders[e] = {};
          });
        }
      }
    }
    var jsonString = prettyJson(output);
    var outputFilename = 'app_' + localeKey + '.arb';
    var outputPath = joinDir([arbDir, outputFilename]);
    saveString(outputPath, jsonString);
  }
  trace('arb files generated');
}

String _getArbDir() {
  var intlPath = config.intlYamlPath;
  if (intlPath.isNotEmpty && exists(intlPath)) {
    var data = openString(intlPath);
    if (data.isEmpty) {
      return '';
    }
    var doc = loadYaml(data);
    var arbDir = doc['arb-dir'];
    return joinDir([configProjectDir, arbDir]);
  }
  return '';
}

final _matchArbPlaceholderRegExp = RegExp(r'\{(.+?)\}');

Set<String> _captureArbSet(String str) {
  if (!_matchArbPlaceholderRegExp.hasMatch(str)) return {};
  final wordset = <String>{};
  final matches = _matchArbPlaceholderRegExp.allMatches(str);
  for (var match in matches) {
    wordset.add(str.substring(match.start + 1, match.end - 1));
  }
  return wordset;
}

void buildForIntl(Map<String, Map<String, String>> map) {
  trace("Intl here!");
  // trace(map);
  var firstLan = map.keys.first;

  /// create map!
  trace(firstLan);
  trace(map);
}
