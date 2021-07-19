import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:trcli/src/utils/utils.dart';
import 'package:trcli/translate_cli.dart';

import 'samples.dart';

void createSampleContent() {
  saveString('data/entry/sample.yaml', SampleYamls.sample);
  saveString('data/entry/categories.yaml', SampleYamls.categories);
  saveString('data/entry/news.yaml', SampleYamls.news);

  /// create config yaml
  createSampleConfig();
  trace(
      '$defaultConfigEnvPath and sample files created in ${Directory.current}');

  if (which('code').found) {
    var useOpen = confirm(yellow('Do you wanna open VisualCode?'), defaultValue: false);
    if (useOpen) {
      trace('Opening current folder in VisualCode...');
      sleep(1);
      'code .'.start(nothrow: true, terminal: true);
      // 'code .'.run;
    }
  }
  exit(0);
}
