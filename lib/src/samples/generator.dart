import 'dart:io';
import 'package:dcli/dcli.dart';
import 'package:flutter_translation_sheet/flutter_translation_sheet.dart';

import 'samples.dart';

/// Generates the sample template content when no `fts --config` is provided nor
/// trconfig.yaml is detected in the current working directory.
void createSampleContent() {
  saveString('strings/home.yaml', SampleYamls.home);
  saveString('strings/sample.yaml', SampleYamls.sample);

  /// create config yaml
  createSampleConfig();

  trace(
    'File ${cyan(defaultConfigEnvPath)} and ${cyan("samples/")} created at ${cyan(Directory.current.path)}',
  );

  trace(white('''
Please, open and fill the following details in ${cyan(defaultConfigEnvPath)} and run ${white("fts", bold: true)} again
 
gsheet:
  credentials_path: (if you did not define FTS_CREDENTIALS in your system enviroment)
  spreadsheet_id:
''', bold: false));

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
