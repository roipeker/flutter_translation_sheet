import 'dart:io';

import 'package:flutter_translation_sheet/src/gsheets/gsheets.dart';

import '../../flutter_translation_sheet.dart';

void gsheetError(GSheetsException e) {
  final causeId = e.cause.toLowerCase();
  if (causeId.contains('caller does not have permission')) {
    error('''Error ${e.cause}
${sheet.badCredentialsHelp}
''');
    exit(3);
  }
}
