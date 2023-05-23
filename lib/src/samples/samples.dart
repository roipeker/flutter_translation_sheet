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
#output_json_template: assets/i18n/*.json

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
#param_output_pattern: "{*}"

## Writes the locales for Android resources `resConfig()` in app/build.gradle
## And keeps locales_config.xml updated (for Android 33+)
#output_android_locales: true

dart:
  ## Output dir for dart files
  output_dir: lib/i18n

  output_fts_utils: true
  
  #fts_utils_args_pattern: {}

  ## Translation Key class and filename reference
  keys_id: Strings

  ## Translations map class an filename reference.
  translations_id: Translations

  ## translations as Dart files Maps (practical for hot-reload)
  use_maps: true

## see: https://cloud.google.com/translate/docs/languages
## Watch out for the language codes, they are not the same as the locale codes.
## Follows the ISO-639 standard.
## List of languages to translate your strings.
locales:
  - en
  - es
  - ar

## Google Sheets Configuration
## How to get your credentials?
## see: https://github.com/roipeker/flutter_translation_sheet/wiki/Google-credentials
gsheets:
  ## Use relative or absolute path to your json credentials.
  ## Check the wiki for a step by step tutorial:
  ## https://github.com/roipeker/flutter_translation_sheet/wiki/Google-credentials
  ## Or you can set the var FTS_CREDENTIALS=path/credentials.json in your OS System 
  ## Enviroment.
  credentials_path:
  
  ## Open your google sheet and copy the SHEET_ID from the url:
  ## https://docs.google.com/spreadsheets/d/{SHEET_ID}/edit#gid=0
  spreadsheet_id:

  ## The spreadsheet "table" where your translation will live.
  #worksheet: Sheet1
''';
}

const kLangPickerCupertino = r'''
/// Simple language picker (Cupertino style).
typedef SimpleLangPicker = LangPickerCupertino;
class LangPickerCupertino extends StatefulWidget {
  final Locale selected;
  final ValueChanged<Locale> onSelected;
  final bool changeOnScroll, showFlag, showNativeName, showLocaleCode, looping;

  const LangPickerCupertino({
    super.key,
    required this.selected,
    required this.onSelected,
    this.looping = false,
    this.changeOnScroll = false,
    this.showFlag = false,
    this.showNativeName = true,
    this.showLocaleCode = true,
  });

  @override
  createState() => _LangPickerCupertinoState();
}

class _LangPickerCupertinoState extends State<LangPickerCupertino> {
  @override
  void didUpdateWidget(covariant LangPickerCupertino oldWidget) {
    if (oldWidget.selected != widget.selected ||
      oldWidget.looping != widget.looping ||
      oldWidget.changeOnScroll != widget.changeOnScroll ||
      oldWidget.showFlag != widget.showFlag ||
      oldWidget.showNativeName != widget.showNativeName ||
      oldWidget.showLocaleCode != widget.showLocaleCode
    ) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  late FixedExtentScrollController scrollController;

  LangVo? get selected => AppLocales.of(widget.selected);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: openPicker,
      child: Text(selected?.englishName ?? 'Choose language'),
    );
  }

  Future<void> openPicker() async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        scrollController = FixedExtentScrollController(
          initialItem:
              selected == null ? 0 : AppLocales.available.indexOf(selected!),
        );
        return Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: _buildPicker(),
          ),
        );
      },
    );
    if (!widget.changeOnScroll) {
      var index = scrollController.selectedItem;
      index %= AppLocales.available.length;
      widget.onSelected(AppLocales.available[index].locale);
    }
  }

  Widget _buildPicker() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: CupertinoPicker(
        magnification: 1.22,
        squeeze: 1.2,
        useMagnifier: false,
        itemExtent: 40,
        scrollController: scrollController,
        onSelectedItemChanged: (index) {
          if (widget.changeOnScroll) {
            widget.onSelected(AppLocales.available[index].locale);
          }
        },
        looping: widget.looping,
        children: List<Widget>.generate(
          AppLocales.available.length,
          (index) {
            final vo = AppLocales.available[index];
            return Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showNativeName)
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          vo.nativeName,
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  if (widget.showFlag)
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(vo.flagChar),
                      ),
                    ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        vo.englishName,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  if (widget.showLocaleCode)
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          vo.locale.toString().toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
''';
const kLangPickerMaterial = r'''

/// Dropdown menu with available locales. (Material style)
/// Useful to test changing Locales.
class LangPickerMaterial extends StatelessWidget {
  final Locale? selected;
  final Function(Locale) onSelected;
  const LangPickerMaterial({
    super.key,
    this.selected,
    required this.onSelected,
  });
  @override
  Widget build(BuildContext context) {
    final selectedValue = selected ?? AppLocales.supportedLocales.first;
    return Material(
      type: MaterialType.transparency,
      child: PopupMenuButton<Locale>(
        tooltip: 'Select language',
        initialValue: selectedValue,
        onSelected: onSelected,
        itemBuilder: (_) {
          return AppLocales.available
              .map(
                (e) => PopupMenuItem<Locale>(
                  value: e.locale,
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
                ),
              )
              .toList(growable: false);
        },
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
              Text(AppLocales.of(selectedValue)?.englishName ?? '-')
            ],
          ),
        ),
      ),
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
    final inputMap =
        masterMap ?? $theClassName.byKeys[AppLocales.available.first.key];
        if(inputMap == null) {
          throw Exception("No master map found for locale: \${AppLocales.available.first.key}");
        }
    for (var k in localeMap.keys) {
      output[inputMap[k]!] = localeMap[k]!;
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

// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:ui';
const kFtsUtils = '''
##imports

class Fts {
  static const List<String> _rtlLanguages = <String>[
    'ar',
    'fa',
    'he',
    'ps',
    'ur'
  ];

  static const FtsDelegate delegate = FtsDelegate();
  
  static WidgetsBinding get _binding => WidgetsFlutterBinding.ensureInitialized();
  static bool useMasterTextAsKey = false;
  static Map<String, Map<String, String>> get _translations {
    ##resolveTranslations
  }
  
  static Locale? _locale;
  
  static late Locale fallbackLocale;
  
  static final onSystemLocaleChanged = ValueNotifier(
    deviceLocale,
  );

  static final onLocaleChanged = ValueNotifier(
    AppLocales.supportedLocales.first,
  );

  static TextDirection get textDirection => _textDirection;

  static Locale get locale {
    return _locale ?? AppLocales.supportedLocales.first;
  }

  static var _textDirection = TextDirection.ltr;

  static set locale(Locale value) {
    if (!AppLocales.supportedLocales.contains(value)) {
      Locale? langLocale;
      for (var supportedLocale in AppLocales.supportedLocales) {
        if (supportedLocale.languageCode == value.languageCode) {
          langLocale = supportedLocale;
        }
      }
      if (langLocale != null) {
        if (kDebugMode) {
          print(
              'Full locale "\$value" not found. But a matching language "\$langLocale" was found. Using it');
        }
        value = langLocale;
      } else {
        if (kDebugMode) {
          print('No supported locale found for "\$value"');
        }
        return;
      }
    }
    _locale = value;
    _textDirection = _rtlLanguages.contains(value.languageCode)
        ? TextDirection.rtl
        : TextDirection.ltr;
    onLocaleChanged.value = _locale!;

    ##loadJsonSetLocale
  }

  static void _notifyUpdate() {
    _binding.addPostFrameCallback((timeStamp) {
      _binding.performReassemble();
    });
  }

  static String tr(
    String key, {
    Map<String, Object>? namedArgs,
    List<Object>? args,
  }) {
    if (Fts._locale == null) {
      init();
    }
    late String text;
    final map = _translations;
    if (hasTr(key)) {
      text = map['\$_locale']![key]!;
    } else {
      var fallback = '\$fallbackLocale';
      if (map.containsKey(fallback)) {
        text = map[fallback]![key] ?? key;
      } else {
        text = key;
      }
    }
    
    if (text.contains('@:')) {
      RegExp(r'@:(\\S+)').allMatches(text).forEach((match) {
        final toReplace = match.group(0)!;
        final findKey = match.group(1)!;
        if (!hasTr(findKey)) {
          print('Fts, linked key not found: \$findKey');
        } else {
          text = text.replaceAll(toReplace, findKey.tr());
        }
      });
    }
    
    if (namedArgs != null && namedArgs.isNotEmpty) {
      namedArgs.forEach((key, value) {
        // text = text.replaceAll('{\$key}', '\$value');
        text = text.replaceAll('##namedArgsPattern', '\$value');
      });
    }

    if (args != null && args.isNotEmpty) {
      for (final a in args) {
        text = text.replaceFirst(RegExp(r'##argsPattern'), '\$a');
      }
    }
    return text;
  }

  static bool hasTr(String key) {
    final map = _translations;
    return map['\$_locale']?.containsKey(key) == true;
  }

  static void init({
    Locale? locale,
    Locale? fallbackLocale,
  }) {
    final originalCallback = _binding.platformDispatcher.onLocaleChanged;
    _binding.platformDispatcher.onLocaleChanged = () {
      originalCallback?.call();
      onSystemLocaleChanged.value = _binding.platformDispatcher.locale;
    };
    
    Fts.fallbackLocale = fallbackLocale ?? AppLocales.supportedLocales.first;
    
    ##loadJsonFallback
    
    locale ??= deviceLocale;
    Fts.locale = locale;
  }

  static Locale get deviceLocale => _binding.platformDispatcher.locale;

  ##loadJsonMethod
}

##decodeTranslationMethod

extension FtsStringExtension on String {
  String tr({
    Map<String, Object>? namedArgs,
    List<Object>? args,
  }) =>
      Fts.tr(this, namedArgs: namedArgs, args: args);
}

/// Use `MaterialApp.localizationsDelegates: const [FtsDelegate()],`
/// Basic delegate for TextDirection
class _FtsLocalization implements WidgetsLocalizations {
  const _FtsLocalization();

  @override
  TextDirection get textDirection => Fts.textDirection;
}

class FtsDelegate extends LocalizationsDelegate<WidgetsLocalizations> {
  final localization = const _FtsLocalization();

  const FtsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<WidgetsLocalizations> load(Locale locale) async => localization;

  @override
  bool shouldReload(FtsDelegate old) => false;
}
''';

/// ##loadJsonSetLocale
const kLoadJsonSetLocale = '''
    if (!_translations.containsKey('\$_locale')) {
      _load(_locale!).then((_) {
        _notifyUpdate();
      });
    } else {
      _notifyUpdate();
    }
''';

// ##loadJsonFallback
const kLoadJsonFallback = '''
  _load(Fts.fallbackLocale);
''';

/// ##jsonDir
//##loadJsonMethod
const kLoadJsonMethod = '''
  static Future<void> _load(Locale value) {
    final key = '\$value';
    if (_translations.containsKey(key)) {
      return Future.value();
    }
    return rootBundle
        .loadString('##jsonDir\$key.json')
        .then((data) async {
      final map = await compute(_decodeTranslation, data);
      ##tData.byKeys[key] = map;
      if(useMasterTextAsKey){
        ##tData.byText[key] = ##tData.mapLocaleKeysToMasterText(map);
      }
    });
  }
 ''';

// ##decodeTranslationMethod
const kDecodeTranslationMethod = '''
  Map<String, String> _decodeTranslation(String data) => Map<String, String>.from(jsonDecode(data) as Map);
''';

// ##resolveTranslation
const kResolveTranslationMap = '''
    if (kDebugMode) {
      // reactive to hot reload. 
      return !useMasterTextAsKey ? ##tData.getByKeys() : ##tData.getByText();
    } else {
      // required for hot restart. 
      return !useMasterTextAsKey ? ##tData.byKeys : ##tData.byText;
    }
''';

const kResolveTranslationJson = '''
   return !useMasterTextAsKey ? ##tData.byKeys : ##tData.byText;
''';
