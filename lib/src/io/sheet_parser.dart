import 'dart:convert';
import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:flutter_translation_sheet/flutter_translation_sheet.dart';
import 'package:flutter_translation_sheet/src/gsheets/gsheets.dart';

final sheet = SheetParser();

class SheetParser {
  GSheets get api => _api;
  late final _api = GSheets(config.sheetCredentials);
  Spreadsheet? _sheet;
  late Worksheet _table;

  // late List<List<Cell>> _initialCellRows;
  late List<String> colsHeaders;

  String get spritesheetUrl =>
      'https://docs.google.com/spreadsheets/d/${config.sheetId!}';

  String get credentialEmail =>
      _api.credentials?.email ?? 'somesheet@someid.iam.gserviceaccount.com';

  String get badCredentialsHelp {
    return '''Make sure you shared the spreadsheet with your service account email:
  1 - Open $spritesheetUrl.
  2 - Click "Share" button at the top.
  3 - Add "$credentialEmail" in "Share with people and groups" and click "SEND".
''';
  }

  Future<void> _connect() async {
    if (!config.isValidSheet()) {
      throw 'Invalid GoogleSheet configuration';
    }
    trace('🔌 connecting ...');
    try {
      _sheet = await _api.spreadsheet(
        config.sheetId!,
        render: ValueRenderOption.unformattedValue,
      );
    } catch (e) {
      error('''Error $e
- Check if the Spritesheet ID is correct in config_env.yaml: [gsheets:spreadsheet_id:"${config.sheetId}"]
- $badCredentialsHelp
''');
      exit(2);
    }

    checkAndWarnForLocale();

    var table = _sheet!.worksheetByTitle(config.tableId!);
    if (table != null) {
      _table = table;
    } else {
      final _availableTables =
          _sheet!.sheets.map((element) => '  - ' + element.title).join('\n');
      error('''Worksheet "${config.tableId}" doesn't exists.
Please check your sheet and update your configuration @[gsheets:worksheet:].
Available worksheets:
$_availableTables

Open $spritesheetUrl and check the available tabs at the bottom.
''');
      exit(3);
    }
  }

  Future<bool> hasData() async {
    if (_sheet == null) await _connect();
    final lastRow = await _table.cells.lastRow(
      fromColumn: 1,
      length: 1,
      inRange: true,
    );
    if (lastRow == null) return false;
    return lastRow.isNotEmpty;
  }

  // bool _warnedIterativeCalculationConfig = false;
  // void _warnIterativeCalculation() {
  //   if (_warnedIterativeCalculationConfig) return;
  //   _warnedIterativeCalculationConfig = true;
  // }

  List<String> _generateGoogleTranslateColumn({
    required int fromRow,
    String fromLocale = 'en',
    int fromLocaleCol = 2,
    required String toLocale,
    required int len,
  }) {
    var output = <String>[];
    var fromColumnLetter = _getColumnLetter(fromLocaleCol);
    var toLocaleColumn = remoteHeader.indexOf(toLocale) + 1;
    var toColumnLetter = _getColumnLetter(toLocaleColumn);
    // _warnIterativeCalculation();
    var sanitizedFromLocale = sanitizeLocale(fromLocale);
    var sanitizedToLocale = sanitizeLocale(toLocale);
    for (var i = 0; i < len; ++i) {
      var row = fromRow + i;
      var label = '$fromColumnLetter$row';
      var cellData = '';
      if (!config.useIterativeCache) {
        cellData = 'GOOGLETRANSLATE($label, "$sanitizedFromLocale", "$sanitizedToLocale")';
        // cellData = 'IF(ISBLANK(TRIM($label)), "", $cellData)';
        cellData = 'IF(LEN(TRIM($label)), $cellData, "")';
        cellData = '=$cellData';
      } else {
        var formula = 'GOOGLETRANSLATE($label, "$sanitizedFromLocale", "$sanitizedToLocale")';
        var currentCell = '$toColumnLetter$row';
        cellData = '=IF(IFERROR($currentCell)<>0,$currentCell, $formula)';
        // var cellData = '=IF($currentCell<>"",$currentCell, $formula)';
        // =IF(IFERROR(A1)<>0, A1, GOOGLEFINANCE(...))
        // var formula = '=GOOGLETRANSLATE($label, "$fromLocale", "$toLocale")';
        // var cellData = '=IF(AND(IFERROR($label)<>0,$label<>""),$label, if($label<>"",$formula,""))';
        // var cellData = '=IF($label<>"",$label, $formula)';
      }
      output.add(cellData);
    }
    return output;
  }

  String _getTranslateCell(int row, String toLocale) {
    var masterCol = remoteHeader.indexOf(masterLanguage) + 1;
    var label = _getColumnLetter(masterCol) + '$row';
    String cellData;
    var sanitizedFromLocale = sanitizeLocale(masterLanguage);
    var sanitizedToLocale = sanitizeLocale(toLocale);

    if (!config.useIterativeCache) {
      cellData = '=GOOGLETRANSLATE($label, "$sanitizedFromLocale", "$sanitizedToLocale")';
    } else {
      var formula = 'GOOGLETRANSLATE($label, "$sanitizedFromLocale", "$sanitizedToLocale")';
      var toColumnLetter = remoteHeader.indexOf(toLocale) + 1;
      var currentCell = _getColumnLetter(toColumnLetter) + '$row';
      cellData = '=IF(IFERROR($currentCell)<>0,$currentCell, $formula)';
    }
    return cellData;
  }

  // List<String> _generateGoogleTranslateRow({
  //   required List<String> locales,
  //   required int row,
  //   String masterLocale = 'en',
  //   int offsetCol = 2,
  // }) {
  //   var output = <String>[];
  //   // final masterLocaleCol = _getColumnLetter(2);
  //   /// "en" (or master locale) should not be included.
  //   for (var i = 0; i < locales.length; ++i) {
  //     // var col = i + offsetCol + 1;
  //     // var label = masterLocaleCol + '$row';
  //     var currentLocale = locales[i];
  //     output.add(_getCellGTranslate(row, masterLocale, currentLocale));
  //   }
  //   return output;
  // }

  // String _getCellGTranslate(int row, String from, String to) {
  //   return '=GOOGLETRANSLATE(B$row, "$from", "$to")';
  // }

  /// reset the variables when running watch mode.
  void reset() {
    _headersInited = false;
    remoteHeader.clear();
    localHeader.clear();
    // List<String> remoteHeader=[];
    // List<String> localHeader=[];
    // bool _headersInited = false;
    //
    // late List<String> remoteHeader;
    // late List<String> localHeader;
    // bool _headersInited = false;
  }

  bool _isValidLocale(String locale) {
    return config.locales.contains(locale);
  }

  /// final for easy access.
  List<String> remoteHeader = [];
  List<String> localHeader = [];
  bool _headersInited = false;

  // late String masterLanguage;
  String get masterLanguage {
    return config.locales.first;
  }

  int get masterLanguageCol {
    if (!_headersInited) return -1;
    return remoteHeader.indexOf(masterLanguage) + 1;
  }

  Future<void> _initHeaders() async {
    if (_headersInited) return;
    remoteHeader = await _headerModel();
    print('remote headers:\n - ' + magenta(remoteHeader.join(' | ')));
    localHeader = ['keys', ...config.locales];
    _headersInited = true;
  }

  Future<void> imtired(Map<String, String> map) async {
    if (_sheet == null) await _connect();
    await _initHeaders();
    // masterLanguage = config.locales.first;
    // var remoteMasterLangId = remoteHeader.indexOf(masterLanguage) + 1;

    /// get remote keys
    trace('🔑 getting remote Keys ...');
    var remoteKeys = await _table.values.column(1, fromRow: 1);
    trace('found ${remoteKeys.length} remote Keys 🔑');

    var hasKeys = (remoteKeys.length > 1 && remoteKeys[1].isNotEmpty);
    // var startRow = hasKeys ? remoteKeys.length + 1 : 2;

    // trace(remoteKeys);
    if (!hasKeys) {
      trace('⛔ no remote Keys found, generating...');

      /// no checking needed.
      final keys = map.keys.toList();
      final values = map.values.toList();

      /// direct insert!
      await _table.values.insertColumn(
        1,
        keys,
        fromRow: 2,
      );

      await _table.values.insertColumn(
        masterLanguageCol,
        values,
        fromRow: 2,
      );
    }

    /// how much to fill now ?
    var lastRow = await _getLastRemoteRow();
    // trace('Last remote keys row: ', lastRow);

    /// check each lang separately now.
    trace('Validating header columns...');
    var rowsData = await _table.values.allRows(
      fromColumn: 1,
      count: 2,
      fill: true,
    );

    /// inspect 2nd row with access to header :)
    for (var i = 0; i < rowsData[1].length; ++i) {
      var colData = rowsData[1][i];
      var headerValue = rowsData[0][i];
      if (colData.isEmpty &&
          headerValue.isNotEmpty &&
          localHeader.contains(headerValue)) {
        if (headerValue == masterLanguage) {
          trace('Master language ($headerValue) is corrupt, regenerating.');
          await _table.clearColumn(masterLanguageCol, fromRow: 2);
          await _table.values.insertColumn(
            masterLanguageCol,
            map.values.toList(),
            fromRow: 2,
          );
        } else {
          trace(
              'Auto translate column ${i + 1} ($headerValue) x $lastRow rows');
          var data = _generateGoogleTranslateColumn(
            fromRow: 2,
            fromLocaleCol: masterLanguageCol,
            fromLocale: masterLanguage,
            toLocale: headerValue,
            len: lastRow - 1,
          );
          await _table.values.insertColumn(i + 1, data, fromRow: 2);
        }
      }
    }

    /// --- now let's see what changed.
    /// load remote key + master
    print(yellow('❯') + ' checking changes with the remote keys...');
    var remoteMap = await _getRemoteMap(masterLanguageCol);
    print(yellow('❯') + ' remote keys received ' + green('✓'));

    /// check master language text changes
    trace('Checking remote master String changes...');
    final _rowsToUpdate = <int, List<String>>{};

    List<String> buildGTRow({
      required int row,
      required String keyText,
      required String masterText,
    }) {
      var master = config.locales.first;
      var out = <String>[];
      for (var i = 0; i < remoteHeader.length; ++i) {
        var header = remoteHeader[i];
        if (header == 'keys') {
          out.add(keyText);
        } else if (localHeader.contains(header)) {
          if (header == master) {
            out.add(masterText);
          } else {
            var data = _getTranslateCell(row, header);
            out.add(data);
            // out.add(_getCellGTranslate(row, master, header));
          }
        } else {
          out.add('');
        }
      }
      return out;
    }

    for (var k in map.keys) {
      if (!remoteMap.containsKey(k)) continue;
      var localText = map[k]!;
      var remoteText = remoteMap[k]!;
      if (remoteText != localText) {
        var row = remoteKeys.indexOf(k) + 1;
        _rowsToUpdate[row] = buildGTRow(
          row: row,
          masterText: localText,
          keyText: k,
        );
        trace('- row $row: \n\t', remoteText, '\n\t != \n\t', localText);
      }
    }
    if (_rowsToUpdate.isNotEmpty) {
      trace('Updating ${_rowsToUpdate.length} rows...');
      trace(_rowsToUpdate);
      await _table.batchUpdateRows(_rowsToUpdate);
      trace('Done updating rows with mismatch text.');
    }

    /// REMOVE KEYS

    var deletedKeys = [];
    for (var k in remoteMap.keys) {
      if (!map.containsKey(k) && k.isNotEmpty) {
        deletedKeys.add(k);
      }
    }

    if (deletedKeys.isNotEmpty) {
      trace(
        'keys nonexistent in the local map: \n-',
        deletedKeys.join('  \n- '),
      );

      /// we will delete the rows remotely?
      // var autoDelete = deletedKeys.length < 2;
      var autoDelete = true;
      if (autoDelete) {
        //// clear the fields!
        // _table.batchClearRows(rows)
        var clearRows = <int>[];
        for (var k in deletedKeys) {
          var row = remoteKeys.indexOf(k) + 1;
          clearRows.add(row);
          // await _table.deleteRow(row);
          // remoteMap.remove(k);
          // remoteKeys.remove(k);
          // trace('Row $row deleted.');
        }

        if (clearRows.isNotEmpty) {
          trace(
              '${clearRows.length} rows will be cleared ( ${clearRows.join((', '))} )');
          var result = await _table.batchClearRows(clearRows);
          trace('Clear rows result:', result);
          if (result) {
            clearRows.forEach((row) {
              var k = remoteKeys[row - 1];
              remoteMap.remove(k);
              remoteKeys[row - 1] = '';
              // remoteKeys.remove(k);
            });
            clearRows.clear();
            trace('Rows clearing successful');
          }
        }
      } else {
        /// check if its a batch!
        trace('You will have to manually delete:');
        for (var k in deletedKeys) {
          // _table.clearRow(row, fromColumn: 1, length: 12, count: 20);
          var row = remoteKeys.indexOf(k) + 1;
          trace('- row $row');
        }
      }
    }

    /// ADD NEW KEYS
    var addedKeys = [];
    for (var k in map.keys) {
      if (!remoteMap.containsKey(k)) {
        addedKeys.add(k);
      }
    }
    if (addedKeys.isNotEmpty) {
      trace(
        'new keys inserted:\n - ',
        addedKeys.join('\n - '),
      );

      /// we will add the rows to their positions?
      // var addToEnd = addedKeys.length > 4;
      var addToEnd = true;
      final _keys = map.keys.toList(growable: false);
      if (addToEnd) {
        var lastRow = await _getLastRemoteRow() + 1;
        trace('We will add new records at the end.');

        /// ( row > $lastRow )
        var insertRows = <List<String>>[];
        var row = lastRow;
        for (var k in addedKeys) {
          // ++lastRow;
          // await _table.insertRow(row);
          var rowData = _getNewRowKey(
            row: row,
            key: k,
            text: map[k]!,
            remoteHeader: remoteHeader,
            localHeader: localHeader,
          );
          insertRows.add(rowData);
          ++row;
          // trace('row $row built');
        }
        trace('Inserting ${insertRows.length} record(s)');
        // await _table.values.insertRows(lastRow, insertRows);
        try {
          await _table.values.appendRows(insertRows);
        } catch (e) {
          error('ERROR: $e');
          if (e is GSheetsException) {
            if (e.cause.toLowerCase().contains('not have permission')) {
              error(badCredentialsHelp);
            }
          }
          exit(3);
        }
        trace('🙂 Append rows complete');
      } else {
        for (var k in addedKeys) {
          var row = _keys.indexOf(k) + 2;
          await _table.insertRow(row);
          var rowData = _getNewRowKey(
            row: row,
            key: k,
            text: map[k]!,
            remoteHeader: remoteHeader,
            localHeader: localHeader,
          );
          await _table.values.insertRow(row, rowData);
          trace('row $row built');
        }
      }
    }

    if (remoteKeys.contains('')) {
      var numBlankSpaces = remoteKeys.where((text) => text.isEmpty).length;
      trace('total blank key rows: ', red('$numBlankSpaces'));

      /// TODO: Clean up EMPTY keys.
      if (numBlankSpaces > 1) {
        trace('Empty keys detected: $numBlankSpaces');
        var result = await _removeTableWhitespaces();
        var count = result['replies']?.first['deleteDuplicates']
                ?['duplicatesRemovedCount'] ??
            0;
        trace('Duplicated rows deleted: $count');
      }

      /// detect the first row!🎯
      var firstCleanIndex = remoteKeys.indexOf('');
      if (firstCleanIndex > 1) {
        var row = firstCleanIndex + 1;
        await _table.deleteRow(row);
        print('Empty row ' + red('$row') + ' deleted.');
      }
    }

    // trace('Current row count: ', _table.rowCount);

    // trace(remoteKeys.length, ':', remoteValues.length);
    // trace(remoteMap);
  }

  Future<Map<String, Map<String, String>>> getData() async {
    if (_sheet == null) await _connect();
    await _initHeaders();
    // we need keys and other valid locales != master
    // trace('getting data, remote headers: ', remoteHeader, localHeader);
    // trace('master', masterLanguage, masterLanguageCol);

    trace('Requesting translated locales from GSheet ...');

    /// TODO: query the rows that we need.
    var ranges = <String>[];
    for (var k in localHeader) {
      if (k == masterLanguage) continue;
      var col = remoteHeader.indexOf(k) + 1;
      // trace( "key: ", k, " index: ", col , ' col: ', _getColumnLetter(col));
      var colLetter = _getColumnLetter(col);
      var range = colLetter + '1:' + colLetter;
      ranges.add(range);
    }
    // var res = await _table.batchGet(['A1:A', 'C1:C', 'E1:E2000']);
    final result = await _table.batchGet(ranges);

    trace('Remote locales received.');

    /// assure keys is 1st in list.
    var keys = result.firstWhere((element) => element[0] == 'keys');
    keys.removeAt(0);
    result.remove(keys);

    const loadingTranslation = 'Loading...';

    /// make the map.
    var output = <String, Map<String, String>>{};
    var isLoadingTranslations = false;
    var mapLoading = <String, bool>{};
    for (var langCol in result) {
      var headerKey = langCol.removeAt(0);
      mapLoading[headerKey] = false;
      final localMap = output[headerKey] = <String, String>{};
      for (var i = 0; i < keys.length; ++i) {
        var key = keys[i];
        var value = i >= langCol.length ? '' : langCol[i];
        if (value.contains(loadingTranslation) &&
            mapLoading[headerKey] == false) {
          mapLoading[headerKey] = true;
          trace('$headerKey still is loading translations...');
          isLoadingTranslations = true;
        }
        localMap[key] = value;
      }
    }

    if (isLoadingTranslations) {
      trace(
          'Translations are still loading in the sheet, please, run the cli again.');
    }

    return output;
  }

  List<String> _getNewRowKey({
    required int row,
    required String key,
    required String text,
    required List<String> remoteHeader,
    required List<String> localHeader,
  }) {
    var masterLang = localHeader[1];
    var rowData = List.filled(remoteHeader.length, '');
    rowData[0] = key;

    var masterLangCol = remoteHeader.indexOf(masterLang);
    rowData[masterLangCol] = text;

    for (var i = 2; i < localHeader.length; ++i) {
      var locale = localHeader[i];
      var localeIndex = remoteHeader.indexOf(locale);
      rowData[localeIndex] = _getTranslateCell(row, locale);
    }
    return rowData;
  }

  Future<Map<String, String>> _getRemoteMap(int masterCol) async {
    var remoteKeys = await _table.values.column(1, fromRow: 1);
    var remoteValues = await _table.values.column(masterCol, fromRow: 1);
    if (remoteKeys.length != remoteValues.length) {
      var lang = remoteValues[0];
      throw ('Keys and master lang ($lang) have different number of rows. Please clear your master column.');
    }
    var remoteMap = <String, String>{};
    for (var i = 1; i < remoteKeys.length; ++i) {
      var key = remoteKeys[i];
      var value = remoteValues[i];
      remoteMap[key] = value;
    }
    return remoteMap;
  }

  Future<List<String>> _headerModel() async {
    if (_sheet == null) await _connect();
    trace('checking headers row ... 🔎');
    var configLocales = ['keys', ...config.locales];
    var sheetLocales = await _getHeaders();

    /// do we have space?
    if (_table.columnCount < 100) {
      trace('adjusting number of columns...');
      try {
        await _table.insertColumn(
          _table.columnCount,
          count: 100 - _table.columnCount,
        );
      } catch (e) {
        trace('''ERROR: $e
Are you sure you are using the correct credentials for the sheet?
Please follow https://medium.com/@a.marenkov/how-to-get-credentials-for-google-sheets-456b7e88c430''');
        exit(4);
      }
    }

    var missingLocales = <String>[];
    configLocales.forEach((c) {
      if (!sheetLocales.contains(c)) {
        missingLocales.add(c);
      }
    });

    /// add missing locales to the end.
    if (missingLocales.isNotEmpty) {
      var lastColumn = sheetLocales.length + 1;
      trace('adding missing locales columns: ', missingLocales);
      var result = await _table.values
          .insertRow(1, missingLocales, fromColumn: lastColumn);
      if (!result) {
        throw 'Error adding new locale columns';
      }
      sheetLocales.addAll(missingLocales);
    }
    return sheetLocales;
  }

  Future<List<String>> _getHeaders() async {
    if (_sheet == null) await _connect();
    return await _table.values.row(1, fromColumn: 1);
  }

  Future<void> _deleteEmptyColumns(List<String> sheetLocales) async {
    /// delete empty spaces.
    var deleteColList = [];
    for (var i = 0; i < sheetLocales.length; ++i) {
      if (sheetLocales[i].trim().isEmpty) {
        deleteColList.add(i);
      }
    }
    sheetLocales.removeWhere((element) => element.trim().isEmpty);
    var deleteCalls =
        deleteColList.reversed.map((colId) => _table.deleteColumn(colId + 1));
    return await Future.forEach(
      deleteCalls,
      (element) => element,
    );
  }

  Future<int> _getLastRemoteRow() async {
    var _lastRowInKeys =
        await _table.cells.lastRow(fromColumn: 1, length: 1, inRange: true);
    return _lastRowInKeys!.first.row;
  }

  Future<Map<String, dynamic>> _removeTableWhitespaces() async {
    var id = _table.id;
    var list = [
      {
        'deleteDuplicates': {
          'range': {
            'sheetId': id,
            'startRowIndex': 1,
          },
          'comparisonColumns': [
            {
              'sheetId': id,
              'dimension': 'COLUMNS',
              'startIndex': 0,
              'endIndex': 1,
            }
          ],
        },
      }
    ];
    var result = await _sheet!.batchUpdate(list);
    return jsonDecode(result.body);
  }

  /// Checks if the Sheet has a "valid" locale for the translate formula.
  void checkAndWarnForLocale() {
    /// Using , for formulas
    // all india variants: te_IN,kn_IN,hi_IN,
    // zh_HK,ar_EG,zh_CN,en_CA,es_MX
    // cy_GB,en_GB,en_US,mn_MN,ja_JP,iw_IL,
    final s = _sheet;
    if (s == null) return;
    final locale = s.properties.locale.toLowerCase();
    trace("Sheet's locale ${white(locale)} ");
    final valid1 = ['gb', 'us', 'il', 'in', 'cn', 'jp'].any(locale.endsWith);
    final valid2 = ['zh', 'en'].any(locale.startsWith);
    final valid3 = ['es_mx', 'ar_eg', 'mn_mn'].any(locale.startsWith);
    if (!valid1 && !valid2 && !valid3) {
      trace('''
${red("WARNING!")}
fts uses the US format for the translation formula (using "," as separator instead of ";" )
Seems like your Google Sheet locale is set to ${s.properties.locale}, which is 
potentially incompatible and might show ${red("#ERROR!")} (Formula parse error.)

To fix this, open $spritesheetUrl 
go to ${white("File > Settings")} and under ${white("General")} 
set your Locale to ${cyan("United States")}.

Optionally, follow the steps on https://support.google.com/docs/answer/58515

''');
    }
    // trace("Super local", _sheet?.properties.locale);
  }
}

/// Sanitize to Google Translate language code.
/// https://cloud.google.com/translate/docs/languages
/// Full locales are usually not allowed and will display an ERROR.

final _sanitizeLocaleCached = <String, String>{

};

String sanitizeLocale(String locale, {bool throwOnError = false, bool verbose=true}) {
  if(_sanitizeLocaleCached[locale] != null) {
    return _sanitizeLocaleCached[locale]!;
  }
  var originalLocale = locale;
  /// ISO-639 codes
  locale = locale.replaceAll('_', '-');
  if (locale.contains('-')) {
    if (kLangIsoAllowed.contains(locale.toLowerCase())) {
      _sanitizeLocaleCached[originalLocale] = locale;
      return locale;
    }
    final lang = locale.split('-')[0];
    if (lang.length < 2 || lang.length > 3) {
      if (throwOnError) {
        throw 'Invalid language code "$locale"';
      } else {
        return lang;
      }
    }
    final keys = kGoogleLanguages.keys;
    if (!keys.contains(lang)) {
      if (throwOnError) {
        throw 'Invalid language code for GoogleTranslate "$locale"';
      } else {
        return lang;
      }
    }
    if(verbose){
      trace('Using code ISO-639 "$lang" for locale "$originalLocale"');
    }
    _sanitizeLocaleCached[originalLocale] = lang;
    return lang;
  }
  _sanitizeLocaleCached[originalLocale] = locale;
  return locale;
}

/// google codes.
// Language	ISO-639 code
const kLangIsoAllowed = ['zh-cn', 'zh-tw', 'mni-mtei'];
const kGoogleLanguages = {
  'af': 'Afrikaans',
  'sq': 'Albanian',
  'am': 'Amharic',
  'ar': 'Arabic',
  'hy': 'Armenian',
  'as': 'Assamese',
  'ay': 'Aymara',
  'az': 'Azerbaijani',
  'bm': 'Bambara',
  'eu': 'Basque',
  'be': 'Belarusian',
  'bn': 'Bengali',
  'bho': 'Bhojpuri',
  'bs': 'Bosnian',
  'bg': 'Bulgarian',
  'ca': 'Catalan',
  'ceb': 'Cebuano',
  'zh': 'Chinese (Simplified)',
  'zh-CN': 'Chinese (Simplified)',
  'zh-TW': 'Chinese (Traditional)',
  'co': 'Corsican',
  'hr': 'Croatian',
  'cs': 'Czech',
  'da': 'Danish',
  'dv': 'Dhivehi',
  'doi': 'Dogri',
  'nl': 'Dutch',
  'en': 'English',
  'eo': 'Esperanto',
  'et': 'Estonian',
  'ee': 'Ewe',
  'fil': 'Filipino (Tagalog)',
  'fi': 'Finnish',
  'fr': 'French',
  'fy': 'Frisian',
  'gl': 'Galician',
  'ka': 'Georgian',
  'de': 'German',
  'el': 'Greek',
  'gn': 'Guarani',
  'gu': 'Gujarati',
  'ht': 'Haitian Creole',
  'ha': 'Hausa',
  'haw': 'Hawaiian',
  'he': 'Hebrew',
  'iw': 'Hebrew',
  'hi': 'Hindi',
  'hmn': 'Hmong',
  'hu': 'Hungarian',
  'is': 'Icelandic',
  'ig': 'Igbo',
  'ilo': 'Ilocano',
  'id': 'Indonesian',
  'ga': 'Irish',
  'it': 'Italian',
  'ja': 'Japanese',
  'jv': 'Javanese',
  'jw': 'Javanese',
  'kn': 'Kannada',
  'kk': 'Kazakh',
  'km': 'Khmer',
  'rw': 'Kinyarwanda',
  'gom': 'Konkani',
  'ko': 'Korean',
  'kri': 'Krio',
  'ku': 'Kurdish',
  'ckb': 'Kurdish (Sorani)',
  'ky': 'Kyrgyz',
  'lo': 'Lao',
  'la': 'Latin',
  'lv': 'Latvian',
  'ln': 'Lingala',
  'lt': 'Lithuanian',
  'lg': 'Luganda',
  'lb': 'Luxembourgish',
  'mk': 'Macedonian',
  'mai': 'Maithili',
  'mg': 'Malagasy',
  'ms': 'Malay',
  'ml': 'Malayalam',
  'mt': 'Maltese',
  'mi': 'Maori',
  'mr': 'Marathi',
  'mni-Mtei': 'Meiteilon (Manipuri)',
  'lus': 'Mizo',
  'mn': 'Mongolian',
  'my': 'Myanmar (Burmese)',
  'ne': 'Nepali',
  'no': 'Norwegian',
  'ny': 'Nyanja (Chichewa)',
  'or': 'Odia (Oriya)',
  'om': 'Oromo',
  'ps': 'Pashto',
  'fa': 'Persian',
  'pl': 'Polish',
  'pt': 'Portuguese (Portugal, Brazil)',
  'pa': 'Punjabi',
  'qu': 'Quechua',
  'ro': 'Romanian',
  'ru': 'Russian',
  'sm': 'Samoan',
  'sa': 'Sanskrit',
  'gd': 'Scots Gaelic',
  'nso': 'Sepedi',
  'sr': 'Serbian',
  'st': 'Sesotho',
  'sn': 'Shona',
  'sd': 'Sindhi',
  'si': 'Sinhala (Sinhalese)',
  'sk': 'Slovak',
  'sl': 'Slovenian',
  'so': 'Somali',
  'es': 'Spanish',
  'su': 'Sundanese',
  'sw': 'Swahili',
  'sv': 'Swedish',
  'tl': 'Tagalog (Filipino)',
  'tg': 'Tajik',
  'ta': 'Tamil',
  'tt': 'Tatar',
  'te': 'Telugu',
  'th': 'Thai',
  'ti': 'Tigrinya',
  'ts': 'Tsonga',
  'tr': 'Turkish',
  'tk': 'Turkmen',
  'ak': 'Twi (Akan)',
  'uk': 'Ukrainian',
  'ur': 'Urdu',
  'ug': 'Uyghur',
  'uz': 'Uzbek',
  'vi': 'Vietnamese',
  'cy': 'Welsh',
  'xh': 'Xhosa',
  'yi': 'Yiddish',
  'yo': 'Yoruba',
  'zu': 'Zulu',
};

final int _char_a = 'A'.codeUnitAt(0);

String _getColumnLetter(int index) {
  var number = index - 1;
  final remainder = number % 26;
  var label = String.fromCharCode(_char_a + remainder);
  number = number ~/ 26;
  while (number > 0) {
    var remainder = number % 26 - 1;
    label = '${String.fromCharCode(_char_a + remainder)}$label';
    number = number ~/ 26;
  }
  return label;
}
