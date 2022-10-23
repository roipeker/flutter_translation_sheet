import 'package:flutter_translation_sheet/flutter_translation_sheet.dart';
import 'package:io/ansi.dart';

Future<void> showGoogleLocaleList() async {
  trace('Valid language codes for GSheets:');

  final configLocales = config.locales
      .map(
        (e) => sanitizeLocale(
          e,
          throwOnError: false,
          verbose: false,
        ),
      )
      .toList(growable: false);

  kGoogleLanguages.forEach((key, value) {
    final isConfigured = configLocales.contains(key);
    var a = wrapWith(key, [styleBold, styleBlink, lightCyan]);
    var out = a!.padRight(25, ' ') + value;
    var char = isConfigured ? '✓' : ' ';
    trace('  $char  - $out');
    // var out = styleBold.wrap(key).toString().padRight(8, '.') + value;
    // trace('$key $value');
    // localesOptions.add('- $out');
    // localesOptions.add('- $key $value');
  });

  // kGoogleLanguages.forEach((key, value) {
  //   var a = wrapWith(key, [styleBold, styleBlink, lightCyan]);
  //   var out = a!.padRight(25, ' ') + value;
  //   // var out = styleBold.wrap(key).toString().padRight(8, '.') + value;
  //   // trace('$key $value');
  //   trace('- $out');
  // });
}
