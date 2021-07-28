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
  // replaces locales in the InfoPlist if available (only on Macos)
  // <key>CFBundleLocalizations</key>
  // <array>
  // <string>en</string>
  // <string>ar</string>
  // </array>
  var infoPath = buildPath([config.iosDirPath, 'Runner', 'Info.plist']);
  if (!exists(infoPath)) {
    trace('Cant find the project ios folder to update locales. Skipping');
    return;
  }
  if (which('plutil').found) {
    /// get locales :)
    var localesString = jsonEncode(config.locales);
    var cmd =
        'plutil -replace CFBundleLocalizations -json \'$localesString\' $infoPath';
    cmd.run;
    trace('📲 locales for iOS updated:\n - $infoPath:');
  }
}
