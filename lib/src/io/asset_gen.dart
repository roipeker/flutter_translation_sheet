import 'package:flutter_translation_sheet/flutter_translation_sheet.dart';

void saveLocaleAsset(String localeName, KeyMap map, {bool beautify = false}) {
  if (!localeName.endsWith('.json')) {
    localeName += '.json';
  }
  var path = joinDir([config.outputJsonDir, localeName]);
  trace('Saving locale asset "$localeName" in ', path);
  saveJson(path, map, beautify: beautify);
}
