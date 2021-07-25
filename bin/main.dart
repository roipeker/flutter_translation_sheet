import 'dart:io';

import 'package:flutter_translation_sheet/src/runner.dart';

Future<void> main(List<String> args) async {
  // var a = 'Aca hay {{{{123}} items {a} and 3';

  //
  // var res = _captureGoogleTranslateVar.allMatches(a);
  // res.forEach((e) {
  //   var key = e.group(0)!;
  //   var res2 = key.replaceAll(_replaceAndLeaveDigitVar, '');
  //   print(res2);
  // });
  // print(a);
  exit(await FTSCommandRunner().run(args));
}
