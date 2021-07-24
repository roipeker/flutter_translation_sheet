import 'package:dcli/dcli.dart';
import 'package:yaml/yaml.dart';

import '../../flutter_translation_sheet.dart';

const _pluralKeysValid = {'one', 'zero', 'other', 'many', 'few', 'two'};
const _pluralMandatory = 'other';
const _kPluralSearch = '.plural:';

void buildArb(Map<String, Map<String, String>> map) {
  trace('Building arb files');
  var appName = '';
  // detect if we have a l10n.yaml file.
  var arbDir = _getArbDir();
  if (arbDir.isEmpty) {
    error(
        '''ERROR: $defaultConfigEnvPath, intl package support is enabled [intl:enabled:true]
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
    var pluralMaps = <String, dynamic>{};
    // make arb file.
    for (var k in localeMap.keys) {
      if (k.contains(_kPluralSearch)) {
        /// take real id.
        var idx1 = k.indexOf(_kPluralSearch);
        var targetKey = k.substring(0, idx1);
        targetKey = targetKey.camelCase;
        pluralMaps[targetKey] ??= {};

        /// special case
        var keys = k.split('.');
        var pluralToken = keys[keys.length - 2];
        if (!pluralToken.contains(':')) {
          error(
              '''plural tokens must declare the variable they use, in the form of "plural:variable:". Sample:
counter:
  plural:count:
    zero: no messages
    one: you have 1 message
    other: you have {{count}} messages.
          ''');
          continue;
        }
        if (!(pluralMaps[targetKey] as Map).containsKey('var')) {
          // var variableName = pluralToken.split(':').last;
          pluralMaps[targetKey]['var'] = pluralToken.split(':').last;
        }
        var pluralKey = keys.last;
//         if (!_pluralKeysValid.contains(pluralKey)) {
//           error('''Invalid plural key detected in "$k"
//  Valid types: $_pluralKeysValid
//  Mandatory type: $_pluralMandatory
// ''');
//         } else {
          pluralMaps[targetKey][pluralKey] = localeMap[k];
        // }
      } else {
        var newKey = k.camelCase;
        var textValue = localeMap[k]!;
        output[newKey] = textValue;
        // trace('the key is $k ///// $newKey');
        _addMetaKey(newKey, textValue, output);
      }
    }
    /// add pluralKeys
    for (var k in pluralMaps.keys) {
      output[k] = _resolvePluralTextFromMap(pluralMaps[k]);
      _addMetaKey(k, output[k], output);
    }
    var jsonString = prettyJson(output);
    var outputFilename = 'app_' + localeKey + '.arb';
    var outputPath = joinDir([arbDir, outputFilename]);
    saveString(outputPath, jsonString);
  }
  trace('arb files generated');
  // runPubGet();
}

void _addMetaKey(String newKey, String textValue, Map output) {
  /// add description always.
  late Map placeholders;

  /// check if the property had metadata.
  final metaKey = '@$newKey';
  if (metaProperties.containsKey(metaKey)) {
    output[metaKey] = metaProperties[metaKey];
  } else {
    output[metaKey] = <String, dynamic>{};
  }
  // output[metaKey]['description'] ??= 'This String was assigned in $newKey';
  if (output[metaKey].containsKey('placeholders')) {
    placeholders = {}..addAll(output[metaKey]['placeholders']);
  } else {
    placeholders = {};
  }
  if (textValue.contains('{') && textValue.contains('}')) {
    /// get properties back!
    var res = _captureArbSet(textValue);
    if (res.isNotEmpty) {
      res.forEach((e) {
        /// if we already have "metaProperties", don't override.
        if (!placeholders.containsKey(e)) {
          placeholders[e] = {};
        }
      });
    }
  }
}

String _resolvePluralTextFromMap(Map map) {
  var str = '';
  if (!map.containsKey(_pluralMandatory)) {
    error('Plural objects must contain the type "other" as default.');
  }
  // =0{No contacts}=1{{howMany} contact}=2{{howMany} contacts}few{{howMany} contacts}many{{howMany} contacts}other{{howMany} contacts}}
  // "{howMany,plural, =0{No contacts}=1{{howMany} contact}=2{{howMany} contacts}few{{howMany} contacts}many{{howMany} contacts}other{{howMany} contacts}}",
  var varKey = map.remove('var');
  str += '{$varKey,plural, ';
  for (var k in map.keys) {
    str += '$k{${map[k]}}';
  }
  str += '}';
  return str;
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
