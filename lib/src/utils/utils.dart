import 'dart:convert';
import 'dart:io';

import '../common.dart';
import 'logger.dart';

export 'logger.dart';
export 'json2yaml.dart';

String prettyJson(dynamic json) {
  return JsonEncoder.withIndent('  ' * 2).convert(json);
}

void saveString(String path, String content) {
  var f = File('$path');
  if (!f.existsSync()) {
    f.createSync(recursive: true);
  }
  var point = f.openSync(mode: FileMode.write);
  point.writeStringSync(content);
  point.closeSync();
}

String openString(String path) {
  // if (useDataDir && !path.startsWith('data/')) {
  //   path = 'data/master/$path';
  // }
  var f = File(path);
  if (f.existsSync()) return f.readAsStringSync();
  print('openString(): ${f.uri} does not exists.');
  return '';
}

String joinDir(List<String> paths) {
  return paths.join('/').replaceAll('//', '/');
}

Future<File> moveFile(File sourceFile, String newPath) async {
  try {
    // prefer using rename as it is probably faster
    return await sourceFile.rename(newPath);
  } on FileSystemException catch (e) {
    // if rename fails, copy the source file and then delete it
    final newFile = await sourceFile.copy(newPath);
    await sourceFile.delete();
    return newFile;
  }
}

JsonMap openJson(String filepath) {
  final str = openString(filepath);
  if (str.isEmpty) {
    trace('file "$filepath" doesnt exist. Empty json returned');
    return Map<String, String>.identity();
  }
  return jsonDecode(str) as JsonMap;
}

void saveJson(String filepath, dynamic json, {bool beautify = false}) {
  String str;
  if (json is! String) {
    str = beautify ? prettyJson(json) : jsonEncode(json);
  } else {
    str = '$json';
  }
  saveString(filepath, str);
}

String normLocale(String localeString) {
  localeString = localeString.trim().replaceAll('_', '-').toLowerCase();
  return localeString.split('-').take(2).join('-');
}
