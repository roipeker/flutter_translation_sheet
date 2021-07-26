import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:flutter_translation_sheet/flutter_translation_sheet.dart';
import 'package:flutter_translation_sheet/src/utils/utils.dart';

import 'samples.dart';

void createSampleContent() {
  saveString('assets/fts/categories.yaml', SampleYamls.categories);
  saveString('assets/fts/sample.yaml', SampleYamls.sample);
  /// create config yaml
  createSampleConfig();
  trace(
      '$defaultConfigEnvPath and sample files created in ${Directory.current}');
  // if (which('code').found) {
  //   var useOpen =
  //       confirm(yellow('Do you wanna open VisualCode?'), defaultValue: false);
  //   if (useOpen) {
  //     trace('Opening current folder in VisualCode...');
  //     sleep(1);
  //     'code .'.start(nothrow: true, terminal: true);
  //     // 'code .'.run;
  //   }
  // }
  exit(0);
}
