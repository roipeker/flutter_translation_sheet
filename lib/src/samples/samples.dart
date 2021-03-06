/// const strings for templates.
class SampleYamls {
  static const home = ''' 
## Sample home section.
---
title: Home screen
subtitle: Welcome Home
counter: You pressed the counter {{count}} times

''';

  static const sample = '''
## sample translation, entry file.
---
title: Welcome to Flutter Translation Sheet tool
body: |
  This is a sample body
  to check the translation system
  in GoogleSheet

## you can reference other files and folders with [\$ref: path].
## content of the file will be unwrapped into the key.
home:
  \$ref: home.yaml
''';

  static const trconfig = '''
## output dir for json translations by locale
## (*) represents the locale
output_json_template: assets/i18n/*.json

## output dir for arb translations files by locale
## Useful if you have intl setup or "Intl plugin" in your IDE.
## (*) represents the locale
#output_arb_template: lib/l10n/intl_*

## main entry file to generate the unique translation json.
entry_file: strings/sample.yaml

## pattern to applies final variables in the generated json/dart Strings.
## Enclose * in the pattern you need.
## {*} = {{name}} becomes {name}
## %* = {{name}} becomes %name
## (*) = {{name}} becomes (name)
## - Special case when you need * as prefix or suffix, use *? as splitter
## ***?** = {{name}} becomes **name**
param_output_pattern: "{*}"

dart:
  ## Output dir for dart files
  output_dir: lib/i18n

  ## Translation Key class and filename reference
  keys_id: TKeys

  ## Translations map class an filename reference.
  translations_id: TData

  ## translations as Dart files Maps (available in translations.dart).
  use_maps: false

## see: https://cloud.google.com/translate/docs/languages
## All locales to be supported.
locales:
  - en
  - es
  - ja

## Google Sheets Configuration
## How to get your credentials?
## see: https://github.com/roipeker/flutter_translation_sheet/wiki/Google-credentials
gsheets:

  ## For a performance boost on big datasets, to try to use the GoogleTranslate formula once,
  ## enable "Iterative Calculations" manually in your worksheet to avoid the #VALUE error.
  ## Go to:
  ## File > Spreadsheet Settings > Calculation > set "Iterative calculation" to "On"
  ## Or check:
  ## https://support.google.com/docs/answer/58515?hl=en&co=GENIE.Platform%3DDesktop#zippy=%2Cchoose-how-often-formulas-calculate
  use_iterative_cache: false

  ## Use relative or absolute path to your json credentials.
  ## Check the wiki for a step by step tutorial:
  ## https://github.com/roipeker/flutter_translation_sheet/wiki/Google-credentials
  credentials_path:
  
  ## Open your google sheet and copy the SHEET_ID from the url:
  ## https://docs.google.com/spreadsheets/d/{SHEET_ID}/edit#gid=0
  spreadsheet_id:

  ## The spreadsheet "table" where your translation will live.
  worksheet: Sheet1
''';
}

const kSimpleLangPickerWidget = r'''

/// Dropdown menu with available locales.
/// Useful to test changing Locales.
class SimpleLangPicker extends StatelessWidget {
  final Locale? selected;
  final Function(Locale) onSelected;
  const SimpleLangPicker({
    Key? key,
    this.selected,
    required this.onSelected,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _selected = selected ?? AppLocales.supportedLocales.first;
    return PopupMenuButton<Locale>(
      tooltip: 'Select language',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.translate,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(AppLocales.of(_selected)?.englishName ?? '-')
          ],
        ),
      ),
      initialValue: _selected,
      onSelected: onSelected,
      itemBuilder: (_) {
        return AppLocales.available
            .map(
              (e) => PopupMenuItem<Locale>(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            e.englishName,
                            style: const TextStyle(
                              fontSize: 14,
                              letterSpacing: -0.2,
                              fontWeight: FontWeight.w300,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            e.nativeName,
                            style: const TextStyle(
                              fontSize: 11,
                              letterSpacing: .15,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      e.key.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                value: e.locale,
              ),
            )
            .toList(growable: false);
      },
    );
  }
}
''';

/// Generates `mapLocaleKeysToMasterText()` string using the
/// specified [theClassName].
String getCodeMapLocaleKeysToMasterText(String theClassName) {
  return '''
  static Map<String, String> mapLocaleKeysToMasterText(
      Map<String, String> localeMap,
      {Map<String, String>? masterMap,}) {
    final output = <String, String>{};
    final _masterMap =
        masterMap ?? $theClassName.byKeys[AppLocales.available.first.key]!;
    for (var k in localeMap.keys) {
      output[_masterMap[k]!] = localeMap[k]!;
    }
    return output;
  }''';
}

const kAppLocalizations = '''
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

##import_locales

abstract class ##className {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static ##className? of(BuildContext context) {
    return Localizations.of<##className>(context, ##className);
  }

  static const LocalizationsDelegate<##className> delegate = _##classNameDelegate();
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    ##supportedLocales
  ];

  ##interfaseWithAllStrings
}

class _##classNameDelegate extends LocalizationsDelegate<##className> {
  const _##classNameDelegate();

  @override
  Future<##className> load(Locale locale) {
    return SynchronousFuture<##className>(_lookupAppLocalizations(locale));
  }

  @override
  // bool isSupported(Locale locale) => <String>['el', 'en', 'es', 'fa', 'ja', 'ru', 'zh'].contains(locale.languageCode);
  bool isSupported(Locale locale) => <String>[##localesIds].contains(locale.languageCode);

  @override
  bool shouldReload(_##classNameDelegate old) => false;
}

##className _lookupAppLocalizations(Locale locale) {
  
  /// language+country code specified?
  ##localizationSwitchReturn

  throw FlutterError(
    '##className.delegate failed to load unsupported locale "\$locale". This is likely '
    'an issue with the fts localizations generation tool.'
  );
}

''';
