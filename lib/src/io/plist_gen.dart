import 'dart:convert';

import 'package:dcli/dcli.dart';

import '../../flutter_translation_sheet.dart';

void addLocalesInPlist() {
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
    trace('Locales were updated for iOS at $infoPath');
  }
}
