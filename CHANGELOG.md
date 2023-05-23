## [1.0.27]
- upgrade dependencies to work on latest Dart version (^3.0.1). 
- upgrade sdk, packages and fix lint issues

## [1.0.26]
- fix posix path issue (plutil cli call on macos when absolute paths have spaces)
- improved `fts extract`, now skips captured text that's only number, a variable, or a group of chars that have no grapheme (in any charset). 
- add locales to build.gradle resConfigs and android:localeConfig for Android 33+
- added missing language codes from https://cloud.google.com/translate/docs/languages
- added language code sanity check for the GoogleTranslate formula. (full Locales headers are supported now).

## [1.0.25]
- internal fix to check if its running locally in dev mode.
- fix for Windows shell. (thanks @IsmailAlamKhan)
- fixes on `Fts` when loading from json.

## [1.0.24]
- put back dependencies constrains for release.
- put back `fts upgrade` code.

## [1.0.23]
- fix bug with empty `param_output_pattern` and `Fts.tr(namedArgs:)`
- added `fts extract --exclude path1,pathN` to exclude paths from capture.
- added `fts extract --clean` to remove duplicated records.
- added `Fts.useMasterTextAsKey` to use master text as key for translation, for example `"Hello".tr()`
- added `Fts.onSystemLocaleChanged` notifier, receives the events when the window detects a locale change (like on Android 13)
- change pubspec dependencies to NOT force any constrains (and avoid errors on flutter pub get)
- cleaned up code.
- renamed SimpleLangPicker to LangPickerMaterial and added LangPickerCupertino

## [1.0.22]
- fix generated dart files format.
- made "run" the default command when no arguments are passed.
- add support for dev_dependencies.
- add support to read the configuration (key `fts:`) from pubspec.
- add support to read the configuration PATH (key `fts: "path.yaml"`) from pubspec.
- fix some code formatting.
- add support for auto-include json assets folder in pubspec.flutter.assets
- add `Fts` (and utils) to quickly test the internationalization in your app. `output_fts_utils: true` in the configuration.
- add support for `FTS_CREDENTIALS` environment variable.
- hide vars files, rename `vars.lock` to `.vars.lock`
- when `Fts` is used (.tr() extension), you can specify `fts_utils_args_pattern: "%s"` for not-named variables. 
- add support for linked keys in vars, in the format {{@:title}}, fts does not include `param_output_pattern` in those cases.
- add support to resolve linked keys in `Fts` at runtime.
- add support to resolve linked keys at build time (add to root config `resolve_linked_keys: true`).
 

## [1.0.21]
- Fix: .arb variables not being generated.

## [1.0.20]
- added CLI check and warning for Sheet locale to avoid potential errors with the formula.
- updated README.
## [1.0.19]
- updated to dart sdk 2.17.
- removed auto check for upgrade version.
- fixed some styling for text in ANSI color output.
## [1.0.18+39]
- improved code generation to match styling on latest `flutter_lints` in Flutter 2.5
- make TKeys generation camelCase, and ensures no fields ends up private, or illegal (starts with number). 
- updated all dependencies to latest versions.

## [1.0.17+36]
- improved README.md

## [1.0.17+35]
- add support to unwrap long texts `$ref: file.txt`, extension has to be **.txt**. This allows to have long multiline (html/markup) in a plain text file, instead of doing it inside the yaml. 

## [1.0.16+34]
- remove type matching for optionalParameters in arb generation. 
  This avoids issues with the main Type
  Example: `double money` isn't casting `decimalDigits` > `{{money:double:currency(name:"Euro",symbol:"€",decimalDigits:2)}}`

## [1.0.15+33]
- readme fixes.
- fix for locale key in `LangVo`.
- improved `SimpleLangPicker` ui.

## [1.0.15+32]
- dart format.

## [1.0.15+31]
- preparing release for pub.dev

## [1.0.14+30]
- fixed `fts --version` for local development.
- added global catch() for sheet errors, to provide in the future better hints on the errors and possible solutions.
- changed some wording on the error messages.
- made some preparations files for a future init command.
- custom arb placeholders are STILL broken. Should be revisit asap.

## [1.0.14+29]
- Fixed the upgrade `fts upgrade` command.
- Fix sorting of export file under [dart:output_dir]

## [1.0.14+27]

- add `fts run --watch` to keep listening for file system changes in the config file and the directory that holds your master strings (entry_file parent folder).
- [LangVo.flagChar] to read the flag "emojis" if supported by the system.
- add default dart exports for [config.dart.output_dir] file.
- add dart reserved words checking (and replacer) for the master strings tag, when generating TKeys files.

## [1.0.13+25]

- add dart variable capture from interpolated strings in `fts extract`.
- updated README

## [1.0.12+23]

- fix version check for upgrades
- added a better template in "example/"
- force MacOs validation to run Info.plist edition. (Some linux distros have the plutil)
- code docs.

## [1.0.12+22]

- fix wrong paths for the sample template.

## [1.0.11+21]

- change default trconfig.yaml template
- added SimpleLangPicker Widget to simplify locale change.
- added [TData.byKeys], [TData.getByKeys()], [TData.byText], [TData.getByText()] to support hot reload on Maps.
- [TData.byText / TData.getByText()] allows you to Map your keys to your master language String.
- added [TData.mapLocaleKeysToMasterText()] for the ability to convert keys to master string texts on demand.
- added [AppLocales.systemLocale] and [AppLocales.systemLocales] utility to retrieve the system locale.

## [1.0.10+20]

- force absolute paths.

## [1.0.9+19]

- fix version mismatch.

## [1.0.9+18]

- README improvements.
- new arguments inside variables.
- fixes Locale canonicalization, now uses the Flutter way: en_US instead of en-us
- fixes Intl generator error when only languageCode_countryCode is defined (without the languageCode only fallback).
- Much improved RegExp for variable detection in GoogleSheet cells, when GoogleTranslate corrupts the format breaking the generated code.
- Automatic iOS Info.plist sync with locales (only macos).

## [1.0.8+17]

- Improved support for `arb` generation based on `intl` standards!
- Fixed error for clearing unused rows when you have more than one worksheet.
- README improvements.

## [1.0.8+16]

- Improved support for `arb` generation based on `intl` standards!
- README improvements.

## [1.0.7+15]

- improved `extract` with --ext and --permissive options to search for more file types, and allow capturing strings without spaces.
- new [intl:enabled:true] option in trconfig.yaml to output `arb` files in lib.
- other minor improvements. Still need to add docs and test new features.

argParser.addOption('ext', defaultsTo: 'dart', abbr: 'e', help: 'Comma separated list of allowed file extensions types to analyze for strings.');
argParser.addFlag('permissive', abbr: 's', help: 'Toggles permissive mode, capturing strings without spaces in it.');

## [1.0.6+15]

- small README fixes and formatting files.

## [1.0.6+14]

- small README fixes.

## [1.0.6+13]

- added `extract` command to get find strings in your dart files.
- added `extract` docs to README.

## [1.0.5+11]

- fixed README issues

## [1.0.5+10]

- changed repo name and package name to **flutter_translation_sheet**
- improved README with badges.

## [1.0.5]

- rebranded to "Flutter Translation Sheet Generator"
- changed cli program to `fts`
- clean docs.
- added `AppLocales.of(locale)` to search for `LangVo` (contains native and english name of the locale).
- added `toString()` methods in Keys classes... that returns the keys 'path.' (might be useful to resolve gender, plurals based on the base key string).

## [1.0.4]

- dynamic string tokens support!! type {{name}},
  and define how to transform the output in config.yaml
- more docs

## [1.0.3]

- string tokens support!! {{name}}
- more docs

## [1.0.2]

- separated the cli in commands: fetch and run
- more docs

## [1.0.1]

- Some fixes and better messages for error exceptions.
- more docs

## [1.0.0]

- Initial version of trcli.
