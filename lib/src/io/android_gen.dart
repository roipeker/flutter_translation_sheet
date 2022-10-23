import 'dart:io';

import 'package:dcli/dcli.dart';

import '../../flutter_translation_sheet.dart';

/// Keeps the iOS Info.plist locales in sync with your trconfig.yaml locales.
/// Only runs on MacOs, as some Linux distributions have a different `plutil`
/// version that throws with the arguments.
void addLocalesInAndroid() {
  if (config.outputAndroidLocales) {
    _buildAndroidLocales(config.androidDirPath);
  }
}

void _buildAndroidLocales(String dirPath) {
  if (!exists(dirPath)) {
    trace('Can\'t locate Android project folder to update locales. Skipping');
    return;
  }

  /// android 13
  var mainPath = buildPath([dirPath, 'app', 'src', 'main']);
  var manifestPath = buildPath([mainPath, 'AndroidManifest.xml']);
  var buildGradlePath = buildPath([dirPath, 'app', 'build.gradle']);
  var localeConfigPath =
      buildPath([mainPath, 'res', 'xml', 'locales_config.xml']);

  var buildGradleString = openString(buildGradlePath);
  if (buildGradleString.isEmpty) {
    trace(
        'Can\'t locate Android build.gradle file to update locales. Skipping');
    return;
  }

  var hasAndroid33 = false;
  var idx1 = buildGradleString.indexOf('compileSdkVersion');
  if (idx1 > -1) {
    var idx2 = buildGradleString.indexOf('\n', idx1);
    var compileSdkVersion = buildGradleString
        .substring(idx1 + 'compileSdkVersion '.length, idx2)
        .trim();
    if (compileSdkVersion == 'flutter.compileSdkVersion') {
      /// we don't care.
    } else {
      var versionNumber = int.tryParse(compileSdkVersion);
      if (versionNumber != null) {
        if (versionNumber >= 33) {
          hasAndroid33 = true;
          trace('Android 33+ detected');
        }
      }
    }
  }

  var manifestString = openString(manifestPath);
  if (manifestString.isEmpty) {
    trace('Can\'t locate AndroidManifest.xml');
  }

  if (!manifestString.contains(_kManifestLocaleConfigAttr) && hasAndroid33) {
    trace(
        'If you plan to support Android 13+ you need to add the following line to your AndroidManifest.xml <application>:');
    trace(cyan('   android:localeConfig="@xml/locales_config" '));
  }
  // locales_config.xml
  saveString(localeConfigPath, _localesConfigXml());
  trace('locales for Android 13 updated:\n - $localeConfigPath:');

  /// add gradle config res support?
  if (buildGradleString.contains('resConfigs')) {
    print('resConfigs() detected in build.gradle, updating...');
    var regex = RegExp(r'resConfigs\((.*)\)');
    var output = buildGradleString.replaceAll(regex, _resConfigs());
    saveString(buildGradlePath, output);
  } else {
    trace('No resConfigs() detected in build.gradle, adding...');
    var replacer = '''defaultConfig {
        ${_resConfigs()}
''';
    var output = buildGradleString.replaceFirst('defaultConfig {\n', replacer);
    saveString(buildGradlePath, output);
  }
}

String _resConfigs() {
  var locales =
      config.locales.map((e) => '"${_safeAndroidLocale(e)}"').join(', ');
  return 'resConfigs($locales)';
}

String _safeAndroidLocale(String locale) {
  return locale.replaceAll('_', '-');
}

String _localesConfigXml() {
  var outputList = <String>[];
  for (var locale in config.locales) {
    /// use - or _ for locale?
    outputList
        .add(_kLocaleItem.replaceFirst('##name', _safeAndroidLocale(locale)));
  }
  return _kLocaleConfig.replaceFirst('##items', outputList.join('\n'));
}

const _kManifestLocaleConfigAttr = 'android:localeConfig="@xml/locales_config"';
const _kLocaleItem = '  <locale android:name="##name"/>';
const _kLocaleConfig = '''
<?xml version="1.0" encoding="utf-8"?>
<locale-config xmlns:android="http://schemas.android.com/apk/res/android">
##items
</locale-config>
''';
