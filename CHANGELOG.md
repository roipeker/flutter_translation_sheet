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
