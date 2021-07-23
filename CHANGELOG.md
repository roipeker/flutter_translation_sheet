## [1.0.7+15]
- improved `extract` with --ext and --permissive options to search for more file types, and allow capturing strings without spaces.
- new [intl:enabled:true] option in trconfig.yaml to output `arb` files in lib.
- other minor improvements. Still need to add docs and test new features. 

argParser.addOption('ext', defaultsTo: 'dart', abbr: 'e', help: 'Comma separated list of allowed file extensions types to analyze for strings.');
    argParser.addFlag('permissive', abbr: 's', help: 'Toggles permissive mode, capturing strings without spaces in it.');
    
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
