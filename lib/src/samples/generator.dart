import 'dart:io';
import 'package:flutter_translation_sheet/flutter_translation_sheet.dart';
import 'package:flutter_translation_sheet/src/utils/utils.dart';

import 'samples.dart';

/// Generates the sample template content when no `fts --config` is provided nor
/// trconfig.yaml is detected in the current working directory.
void createSampleContent() {
  saveString('strings/home.yaml', SampleYamls.home);
  saveString('strings/sample.yaml', SampleYamls.sample);

  /// create config yaml
  createSampleConfig();
  trace('''Please, fill
  
gsheet:
  credentials_path:
  spreadsheet_id:
  worksheet:
  
in $defaultConfigEnvPath and run the command again.''');
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

void createSampleConfig() {
  saveString(defaultConfigEnvPath, SampleYamls.trconfig);
}
