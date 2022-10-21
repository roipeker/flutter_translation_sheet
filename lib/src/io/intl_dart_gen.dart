import '../../flutter_translation_sheet.dart';

// const _pluralKeysValid = {'one', 'zero', 'other', 'many', 'few', 'two'};
const _pluralMandatory = 'other';
const _selectorMandatory = 'other';
const _kPluralSearch = '.plural:';
const _kSelectorSearch = '.selector:';
const _errorStringInvalidPlural =
    '''plural tokens must declare the variable they use, in the form of "plural:variable:". Sample:
counter:
  plural:count:
    zero: no messages
    one: you have 1 message
    other: you have {{count}} messages.
          ''';

const _errorStringInvalidSelector =
    '''selector tokens must declare the variable they use, in the form of "selector:variable:". Sample:
welcomeUser:
  selector:role:
    admin: Hello admin!
    manager: Hello manager!
    other: Hello visitor.
          ''';

Map<String, dynamic> metaFallbackProperties = {};
Map<String, dynamic> varsByKeys = {};

/// Creates the `{locale}.arb` files to be used by intl package or similar.
/// when `config.yaml` has `intl:enabled:true`.
/// Takes the [map] with all the translations to generates the files.
void buildArb(Map<String, Map<String, String>> map) {
  trace('Building arb files ... ');
  var appName = '';
  // detect if we have a l10n.yaml file.
  // var arbDir = config.arbOutputDir;

  /// look for base locales.
  var sublist = config.locales.where((element) => element.contains('_'));
  sublist.forEach((e) {
    var langCode = e.split('_').first;
    if (!map.containsKey(langCode)) {
      trace('Adding base langCode: $langCode for arb generation');
      map[langCode] = map[e]!;
    }
  });

  for (var localeKey in map.keys) {
    // trace('my locale key: ', localeKey);
    final output = <String, dynamic>{
      '@@last_modified': DateTime.now().toIso8601String(),
      '@@locale': localeKey,
      // special case for countryCode, add base language as well zh-tw
      if (appName.isNotEmpty) 'appName': '$appName',
    };
    var localeMap = map[localeKey]!;
    final pluralMaps = <String, dynamic>{};
    final selectorMaps = <String, dynamic>{};

    // make arb file.
    for (var k in localeMap.keys) {
      if (k.contains(_kSelectorSearch)) {
        _customModifier(
          key: k,
          value: localeMap[k] as String,
          searchKey: _kSelectorSearch,
          targetMap: selectorMaps,
          errorOnVar: _errorStringInvalidSelector,
          // metaVarType: 'String',
        );
      } else if (k.contains(_kPluralSearch)) {
        _customModifier(
          key: k,
          value: localeMap[k] as String,
          searchKey: _kPluralSearch,
          targetMap: pluralMaps,
          errorOnVar: _errorStringInvalidPlural,
          // metaVarType: 'num',
        );
      } else {
        var newKey = k.camelCase;
        var textValue = localeMap[k]!;
        output[newKey] = textValue;

        /// we are sending the original Key ("k", field name separated by dots)
        /// to make compatible with `varsByKeys` accessible and read keys.
        _addSimpleVarsMetadata(k, newKey, textValue, output);
        // _addMetaKey(newKey, textValue, output, metaFallbackProperties);
      }
    }

    /// add pluralKeys
    for (var k in pluralMaps.keys) {
      /// add meta keys
      output[k] = _resolvePluralTextFromMap(pluralMaps[k]);
      _addMetaKey(k, output[k], output, metaProperties);
      _addMetaKey(k, output[k], output, metaFallbackProperties);
    }

    /// add selector keys
    for (var k in selectorMaps.keys) {
      output[k] = _resolveSelectorTextFromMap(selectorMaps[k]);
      _addMetaKey(k, output[k], output, metaProperties);
      _addMetaKey(k, output[k], output, metaFallbackProperties);
    }
    var jsonString = prettyJson(output);
    var outputPath = config.getArbFilePath(localeKey);
    saveString(outputPath, jsonString);
  }
  trace('arb files generated');
  // runPubGet();
}

/// generate the metadata key directly from the message if it contains
/// placeholders.
void _addSimpleVarsMetadata(
  String originalKey,
  String targetKey,
  String value,
  Map<String, dynamic> output,
) {
  var metaKey = '@' + targetKey;
  if (varsByKeys.containsKey(originalKey)) {
    output[metaKey] = <String, dynamic>{
      'description': 'Auto-generated for $originalKey',
    };

    /// add the placeholders in the meta key.
    output[metaKey]['placeholders'] ??= <String, dynamic>{};

    /// clean the placeholder in the original `key`.
    output[targetKey] = _saveVarsFromString(
      value,
      output[metaKey]['placeholders'],
    );
  }
}

/// Parses and adds the needed @metadata for arb files.
void _customModifier({
  required String key,
  required String value,
  required String searchKey,
  String? metaVarType,
  required Map targetMap,
  required String errorOnVar,
}) {
  var idx1 = key.indexOf(searchKey);
  var targetKey = key.substring(0, idx1);
  targetKey = targetKey.camelCase;
  targetMap[targetKey] ??= {};
  var keys = key.split('.');
  var mainToken = keys[keys.length - 2];
  if (!mainToken.contains(':')) {
    error(errorOnVar);
    return;
  }
  if (!(targetMap[targetKey] as Map).containsKey('var')) {
    final _parts = mainToken.split(':');
    targetMap[targetKey]['var'] = _parts[1];
    if (_parts.length > 2) {
      targetMap[targetKey]['varType'] = _parts[2];
    }
  }
  String varToken = targetMap[targetKey]['var']!;
  var varTokenType = targetMap[targetKey]['varType'];
  var selectorKey = keys.last;
  var metaKey = '@' + targetKey;
  metaFallbackProperties[metaKey] ??= <String, dynamic>{
    'description': 'Auto-generated for $targetKey',
  };

  /// get variables from message if any.
  metaFallbackProperties[metaKey]!['placeholders'] ??= <String, dynamic>{};
  if (!metaFallbackProperties[metaKey]!['placeholders'].containsKey(varToken)) {
    var _map = metaFallbackProperties[metaKey]!['placeholders'];
    _map[varToken] = <String, dynamic>{};
    if (metaVarType != null) {
      _map[varToken]!['type'] = metaVarType;
    } else if (varTokenType != null) {
      /// fallback type in key definition.
      /// "selector:gender:String:"
      _map[varToken]!['type'] = varTokenType;
    }
  }
  var _map = metaFallbackProperties[metaKey]!['placeholders'];
  value = _saveVarsFromString(value, _map);
  targetMap[targetKey][selectorKey] = value;
}

// "sampler": "{timer, select, morning {Order your breakfast now} noon {Order your lunch now} night { Order your dinner now} other {Order your snack now.}}",
// "@sampler": {
// "description": "Auto-generated for sampler",
// "placeholders": {
// "timer": {}
// }
// }
// }

/// Adds a new metakey to [output]
void _addMetaKey(String newKey, String textValue, Map output, Map metaMap) {
  /// add description always.
  late Map placeholders;

  /// check if the property had metadata.
  final metaKey = '@$newKey';
  if (metaMap.containsKey(metaKey)) {
    output[metaKey] = Map.from(metaMap[metaKey]);
  } else {
    output[metaKey] = <String, dynamic>{};
  }
  if (output[metaKey].containsKey('placeholders')) {
    placeholders = {}..addAll(output[metaKey]['placeholders']);
  } else {
    placeholders = {};
    if (metaMap.containsKey(metaKey) &&
        metaMap[metaKey].containsKey('placeholders')) {
      placeholders.addAll(metaMap[metaKey]['placeholders']);
    }
  }
  _saveVarsFromString(textValue, placeholders);
}

const _emptyVarMap = <String, dynamic>{};

/// Saves the detected placeholders as `vars.locked` in the `entry_file`
/// basedir.
String _saveVarsFromString(String value, Map saveTo) {
  final textVars = _varsFromString(value);
  // trace("So the::: ", textVars,  ' -- ', value, '-- saveInd:', saveTo);
  var cleanedValue = value;
  if (textVars.isNotEmpty) {
    // trace("CLeaned pre:: ", cleanedValue, '===', textVars);
    textVars.forEach((key, value) {
      /// take complex {vars:type:format(params)} and replace the value with the simple var name.
      if (value is Map && value.containsKey('_text')) {
        cleanedValue = cleanedValue.replaceAll(value['_text'], key);
        value.remove('_text');
      }
      saveTo[key] = value;
      // return saveTo.putIfAbsent(key, () => value);
    });
  }
  // trace("Cleaned value::", cleanedValue);
  return cleanedValue;
}

/// Captures the detected variables from [text].
Map<String, dynamic> _varsFromString(String text) {
  if (text.contains('{') && text.contains('}')) {
    var res = _captureArbSet(text);
    if (res.isNotEmpty) {
      var output = <String, dynamic>{};
      res.forEach((e) {
        /// todo: Analyze more data in the var type.
        if (e.contains(':')) {
          var propData = _buildMetaVarProperties(e);
          output[propData['name']] = propData['data'];
        } else {
          output[e] = {};
        }
      });
      return output;
    }
  }
  return _emptyVarMap;
}

const _kDefaultVarTypeFormats = <String, String>{
  'num': 'decimalPattern',
  'double': 'decimalPattern',
  'int': 'decimalPattern',
  'DateTime': 'yMd',
};

/// capture format/type/parameters from a composed variable {{name:String}}.
Map<String, dynamic> _buildMetaVarProperties(String text) {
  final parts = text.split(':');
  final name = parts.removeAt(0).trim();
  final type = parts.removeAt(0).trim();
  var vo = <String, dynamic>{
    'type': type,
  };

  /// analyze if `type` requires a Format for intl generation.
  if (parts.isEmpty && _kDefaultVarTypeFormats.containsKey(type)) {
    parts.add(_kDefaultVarTypeFormats[type]!);
  }
  if (parts.isNotEmpty) {
    var msg = parts.join(':');
    var startIndex = msg.indexOf('(');
    if (startIndex > -1) {
      vo['format'] = msg.substring(0, startIndex);
      var endIndex = msg.lastIndexOf(')');
      if (endIndex == -1) {
        endIndex = msg.length;
      }
      msg = msg.substring(startIndex + 1, endIndex);
      if (msg.isNotEmpty) {
        vo['optionalParameters'] = <String, dynamic>{};

        /// replace the escaped quotes.
        msg = msg.replaceAll('"', '');
        var params = msg.split(',');
        params.forEach((param) {
          var keyVal = param.split(':');
          if (keyVal.length > 1) {
            final key = keyVal[0].trim();
            final _val = keyVal[1].toLowerCase();
            // late Object? val;
            // if (type == 'num' || type == 'number') {
            //   val = num.tryParse(_val) ?? _val;
            // } else if (type == 'int') {
            //   val = int.tryParse(_val) ?? _val;
            // } else if (type == 'double' || type == 'float') {
            //   val = double.tryParse(_val) ?? _val;
            // } else if (type == 'bool' || type == 'boolean') {
            //   val = _val == 'true' || _val == 'yes' || _val != '0';
            // } else {
            //   val = _val;
            // }
            vo['optionalParameters'][key] = _val;
          } else {
            error('Invalid placeholder format.optionalParameters for $text');
          }
        });
      }
    } else {
      vo['format'] = msg;
    }
  }
  vo['_text'] = text;
  return {
    'name': name,
    'data': vo,
  };
}

/// Usage based on:
/// https://github.com/localizely/flutter-intl-vscode/issues/12#issuecomment-618503796
String _resolveSelectorTextFromMap(Map map) {
  var str = '';
  if (!map.containsKey(_selectorMandatory)) {
    error(
        'select: keys must contain the type "$_selectorMandatory" as default.');
  }

  /// Remove `varType` if we have type info inside the field name.
  /// "selector:gender:String"
  map.remove('varType');
  var varKey = map.remove('var');

  /// Format is critical to be accepted by intl tools.
  /// NO SPACES at the end.
  str += '{$varKey, select,';
  for (var k in map.keys) {
    str += ' $k{${map[k]}}';
  }
  str += '}';
  return str;
}

/// Resolves the plural format in source data (entry_file yaml) and validates
/// the [map].
String _resolvePluralTextFromMap(Map map) {
  var str = '';
  if (!map.containsKey(_pluralMandatory)) {
    error('plural: keys must contain the type "$_pluralMandatory" as default.');
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

/// Returns the folder to save the `.arb` output.
// String _getArbDir() {
//   var intlPath = config.intlYamlPath;
//   if (intlPath.isNotEmpty && exists(intlPath)) {
//     var data = openString(intlPath);
//     if (data.isEmpty) {
//       return '';
//     }
//     var doc = loadYaml(data);
//     var arbDir = doc['arb-dir'];
//     return joinDir([configProjectDir, arbDir]);
//   }
//   return '';
// }

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

// void buildForIntl(Map<String, Map<String, String>> map) {
//   trace('Intl here!');
//   // trace(map);
//   var firstLan = map.keys.first;
//   /// create map!
//   trace(firstLan);
//   trace(map);
// }
