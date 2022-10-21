class CliConfig {
  static const cliName = 'fts';
  static const packageName = 'flutter_translation_sheet';
  static bool isDev = false;
}

abstract class AppStrings {
  /// add all errors here?
  static const kInvalidOutputJsonTemplate =
      '''Invalid pattern supplied for [config::output_json_template]
Use the star char (*) once, its a placeholder for the locale name.

Example:
 - app_*.json > app_en.json
 - *.json > en.json
 - *-i18n > en-i18n.json
''';

  static const kInvalidOutputArbTemplate =
      '''Invalid pattern supplied for [config::output_arb_template]
Use the star char (*) once, its a placeholder for the locale name.

Example:
 - app_*.arb > app_en.arb
 - *.arb > en.arb
 - *-i18n > en-i18n.arb
''';

//   static const kInvalidArbDir = '''ERROR: package support is enabled [intl:enabled:true]
// But 'arb-dir:' is not define or l10n.yaml not found in your target project.
// Please make sure your trconfig.yaml sits in the root of your project, and l10n.yaml as well.
//
// Follow the Flutter documentation for intl:
//
// https://flutter.dev/docs/development/accessibility-and-localization/internationalization#adding-your-own-localized-messages
//
// ''';

}

const kHasAssetsKey = '''
  assets:
''';
const kHasAssetsReplace = '''
  assets:
    - ##replace
''';

const kNoAssetsKey = '''
flutter:
''';
const kNoAssetsReplace = '''
flutter:
  
  assets:
    - ##replace
''';
