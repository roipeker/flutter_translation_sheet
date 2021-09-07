import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:flutter_translation_sheet/src/gsheets/gsheets.dart';
import 'package:googleapis/sheets/v4.dart';

import '../../flutter_translation_sheet.dart';

Future<void> initRun() async {
  // trace('init run called.!');
  // trace('email:', envs['FTS_EMAIL']);
  // // env.
  // // envs.putIfAbsent('FTS_EMAIL', () => 'roipeker@gmail.com');
  // trace('post put email:', envs['FTS_EMAIL']);
  // var path = joinDir([env.HOME, '.fts/settings.json']);
  // var json = openJson(path);
  // trace('json: ', json);
  // trace('fts settings: ', path);
  // exit(0);

  // var json = {'credentials': '123'};
  // saveJson(path, json);
  // print(envs);

  // print(PATH);
  // print(HOME);
  // print(HOME);

  exit(0);
  final myApi = GSheets(
    config.sheetCredentials,
    scopes: [
      SheetsApi.driveScope,
      SheetsApi.driveFileScope,
      SheetsApi.spreadsheetsScope,
    ],
  );

  final res = await myApi.listSpreadsheets();
  res.forEach(print);
  exit(0);
  // final cli = await myApi.client;
  // // final client = await this.client.catchError((_) {
  // //   // retry once on error
  // //   _client = null;
  // //   return this.client;
  // // });
  // // final response = await client.get('$_sheetsEndpoint$spreadsheetId'.toUri());
  // var sheetUrl =
  //     // "https://www.googleapis.com/drive/v3/filesq=mimeType='application/vnd.google-apps.spreadsheet'";
  //     "https://spreadsheets.google.com/feeds/spreadsheets/private/full";
  //
  // sheetUrl =
  //     "https://www.googleapis.com/drive/v3/files?q=mimeType='application/vnd.google-apps.spreadsheet'";
  // final res = await cli.get(Uri.parse(sheetUrl));
  // print("Result: ${res.body}");
  exit(0);
  // myApi.spreadsheet(spreadsheetId)
  // myApi.createSpreadsheet(title)
  // url=;

  var doCreate =
      confirm('Would you like to create a new sheet?', defaultValue: false);
  if (doCreate) {
    var inputName = ask('How do you wanna call it?',
        required: true, defaultValue: 'fts super sheet');
    if (inputName.isEmpty) {
      trace('Can be an empty name, try again');
      exit(2);
    }

    // trace('sheet:', config.sheetCredentials);
    // exit(0);

    var sheetData = await myApi.createSpreadsheet(inputName);
    final msg = '''Sheet created!
Use in your trconfig.yaml=
  
  spreadsheet_id: ${green(sheetData.id)}

Or open the following link in your browser:
https://docs.google.com/spreadsheets/d/${sheetData.id}/edit#gid=0

  ''';
    print(msg);

    var shareResult = await sheetData.share(
      'roipeker@gmail.com',
      // 'mdismailalamkhan@gmail.com',
      // 'leossmith@gmail.com',
      type: PermType.user,
      role: PermRole.writer,
      // withLink: true,
    );
    trace('share result: ', shareResult);
    await Future.delayed(Duration(seconds: 2));

    trace('OK, bye!');

//     try {
//       var sheetData = await myApi.createSpreadsheet(inputName);
//       final msg = '''Sheet created!
// Use in your trconfig.yaml=
//
//   spreadsheet_id: ${green(sheetData.id)}
//
// Or open the following link in your browser:
// https://docs.google.com/spreadsheets/d/${sheetData.id}/edit#gid=0
//
//   ''';
//       print(msg);
//       //
//       // var shareResult = await sheetData.share(
//       //   'roipeker@gmail.com',
//       //   type: PermType.any,
//       //   role: PermRole.owner,
//       //   withLink: false,
//       // );
//       //
//       // trace('share result: ', shareResult);
//       // await Future.delayed(Duration(seconds: 2));
//
//       trace('OK, bye!');
//     } catch (e) {
//       error('Ouch error: ', e);
//     }
  } else {
    trace('bye!');
  }
}
