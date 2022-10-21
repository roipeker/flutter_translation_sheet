import 'dart:convert';
import 'dart:io';

import 'package:dcli/dcli.dart';

import '../../flutter_translation_sheet.dart';

/// Keeps the iOS Info.plist locales in sync with your trconfig.yaml locales.
/// Only runs on MacOs, as some Linux distributions have a different `plutil`
/// version that throws with the arguments.
void addLocalesInPlist() {
  if (!Platform.isMacOS) {
    return;
  }
  _buildAppleLocales(config.iosDirPath, 'iOS');
  _buildAppleLocales(config.macosDirPath, 'MacOS');
}

/// Takes the /ios or /macos [dirPath] and the [name] of the platform to print
/// messages.
/// @see [addLocalesInPlist]
void _buildAppleLocales(String dirPath, String name) {
  var infoPath = buildPath([dirPath, 'Runner', 'Info.plist']);

  if (!exists(infoPath)) {
    trace('Can\'t locate $name project folder to update locales. Skipping');
    return;
  }
  if (which('plutil').found) {
    // replaces locales in the InfoPlist if available (only on Macos)
    // <key>CFBundleLocalizations</key>
    // <array>
    // <string>en</string>
    // <string>ar</string>
    // </array>
    var localesString = jsonEncode(config.locales);
    var cmd =
        'plutil -replace CFBundleLocalizations -json \'$localesString\' "$infoPath"';
    cmd.run;
    trace('locales for $name updated:\n - $infoPath:');
  }
}
