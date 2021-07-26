class SampleYamls {
  static const categories = ''' 
## Sample categories section.
---

title: categories
subtitle: great categories for your app

menu:
  home:
    label: Home
    hint: Tap to go to the home screen

  settings:
    label: Settings
    hint: Tap and check your personal Settings

  users:
    label: Users
    hint: Open the user collection
''';


  static const sample = '''
## sample translation, entry file.
---

title: Welcome to Flutter Translation Sheet tool

body: |
  This is a sample body
  to check the translation system
  in GoogleSheet

header:
  text: "{0}. See {1} to know more about the tool!"
  tag0: Get started with the tool
  tag1: What's new in documentation

## you can reference other files and folders with [\$ref: path].
## content of the file will be unwrapped into the key.
categories:
  \$ref: categories.yaml
''';
}

const kSimpleLangPickerWidget = r'''

class SimpleLangPicker extends StatelessWidget {
  final Locale? selected;
  final Function(Locale) onSelected;

  const SimpleLangPicker({
    Key? key,
    this.selected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _selected = selected ?? AppLocales.supportedLocales.first;
    return PopupMenuButton<Locale>(
      tooltip: 'Select language',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.translate,
              size: 16,
            ),
            SizedBox(width: 8),
            Text(AppLocales.of(_selected)!.englishName)
          ],
        ),
      ),
      initialValue: _selected,
      onSelected: onSelected,
      itemBuilder: (_) {
        return AppLocales.available
            .map(
              (e) => PopupMenuItem<Locale>(
                child: Row(
                  children: [
                    Text(
                      e.key.toUpperCase(),
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      e.englishName,
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      ' (${e.nativeName})',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                value: e.locale,
              ),
            )
            .toList(growable: false);
      },
    );
  }
}
''';

String getCodeMapLocaleKeysToMasterText(String theClassName){
  return '''
  static Map<String, String> mapLocaleKeysToMasterText(
      Map<String, String> localeMap,
      {Map<String, String>? masterMap}) {
    final output = <String, String>{};
    final _masterMap =
        masterMap ?? $theClassName.byKeys[AppLocales.available.first.key]!;
    for (var k in localeMap.keys) {
      output[_masterMap[k]!] = localeMap[k]!;
    }
    return output;
  }''';
}