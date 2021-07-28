![Flutter Tranlsation Sheet header](https://user-images.githubusercontent.com/33768711/127226621-75b35a5e-e50f-45ef-a925-32f4ec6d11d0.png?raw=true)
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-1-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

# Flutter Translation Sheet Generator [fts]

Command line application to make your l10n super fast.
Compose your strings in yaml/json format and use GoogleSheet for auto translate.

[![pub package](https://img.shields.io/pub/v/flutter_translation_sheet.svg?label=fts&logo=Dart&color=blue&style=flat)](https://pub.dev/packages/flutter_translation_sheet)
[![likes](https://badges.bar/flutter_translation_sheet/likes?label:likes&color=blue&style=flat)](https://pub.dev/packages/flutter_translation_sheet/score)
[![style: pedantic](https://img.shields.io/badge/style-pedantic-blue.svg?&style=flat)](https://pub.dev/packages/pedantic)
[![buy me a coffee](https://img.shields.io/badge/buy%20me%20a%20coffee-grey.svg?logo=buy-me-a-coffee&style=flat)](https://www.buymeacoffee.com/roipeker)
![GitHub last commit](https://img.shields.io/github/last-commit/roipeker/flutter_translation_sheet?color=blue&logo=GitHub&style=flat)

![GitHub stars](https://img.shields.io/github/stars/roipeker/flutter_translation_sheet?style=social)
![GitHub forks](https://img.shields.io/github/forks/roipeker/flutter_translation_sheet?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/roipeker/flutter_translation_sheet?style=social)
![GitHub followers](https://img.shields.io/github/followers/roipeker?style=social)

### 🧰 Install:

> You need to have `flutter` or `dart` SDK in your System PATH.

```bash
flutter pub global activate flutter_translation_sheet
```

Now just run `fts` in any folder to create a template configuration file.

Check `--help` on any sub-command of `fts`:
- `fts run`
- `fts fetch`
- `fts extract`
- `fts upgrade`
- `fts --version`

### ⚙️ Usage:

Go with your terminal in any folder (or Flutter project folder), and run `fts run`.

First time will create a template for you, and you will have to get your [Google credentials json](https://medium.com/@a.marenkov/how-to-get-credentials-for-google-sheets-456b7e88c430).

Once you get the json, go to `tfconfig.yaml` and in the `gsheet:` there are two ways to fill the credentials (you only need to use one):

1. Add `credentials_path:` followed by the path of your json. You can copy the json file to the root folder of your project. The path can be absolute or relative.

Example:
```yaml
gsheets:
  credentials_path: c:/my_project/credentials.json or ./credentials.json
```
#### ⚠️ NOTE TO WINDOWS USERS: paths should be either in the form "C:\\\Users\\\etc", with two backslash characters, or using forwardslash characters instead such as "C:/Users/etc". 

2. Add `credentials:` followed by the whole credentials json content

Example:
```yaml
gsheets:
  credentials: {
    "type": "service_account",
    "project_id": "project-id",
    "private_key_id": "",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCB-----END PRIVATE KEY-----\n",
    "client_email": "gsheets@project.iam.gserviceaccount.com",
    "client_id": "123456",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/gsheets%40evolution-cp-calculator.iam.gserviceaccount.com"
  }
```

You can find more information in the comments in `tfconfig.yaml` and fill the `gsheet:` section, and change the output folder as needed.

Once you have your configuration file ready, run `fts` to generate your sample google sheets.

Take the sample data input as reference, and use it in your own project.

**fts** will try to keep the local input and the remote sheet in sync, and automatically generate the locales for you every time you run it.

You can leave a terminal open and use the `run` command while listening for file changes in your master strings folder, or your *trconfig.yaml*:
`fts run --watch`.
You can exit the watch with `q` and then press `Enter`.

⚠️ **Warning**:
> Watch out how often you modify the files and save them. Remember that your Google service account has [usage limits](https://developers.google.com/sheets/api/reference/limits). 


After a while of not using it, Google Sheet performance slow down on every request, so it might take a little longer to get the output generated.
Once it warms up (run 1 time) the sync performance is pretty solid.

```bash
fts fetch
```

Unlike `fts run`, `fetch` doesn't sync, nor validates the data structure.

Uses the local strings as entry map, downloads the latest data from GoogleSheet and generates the files accordingly.
Is a much faster process. Very useful when you made manual corrections in your sheets for the auto-translated locales.

Do not manually modify the *master language* column on your Google Sheet, change the data in the string source file
and let `fts` do the upload.

If there are differences of master lang strings between local and remote, the entire row will be cleared and regenerated with auto translation
using the latest strings, and manual changes will get lost.

Currently you have to be careful, and keep your manual translations backed up just in case you modify the master language string.

### Variables:

To store "variables" or placeholders in your strings to be replaced later in your code, use the follow notation:

```
"Welcome back {{user}}, today is {{date}}."
```

It will store the values in the sheet as {{0}} {{1}} and so on, to avoid complications with GoogleTranslate (although in rare cases GTranslate will truncate the {{}} somehow, don't worry), and it will
generate a *vars.lock* file in the directory where you point your "entry_file" in config.

So you can define your own pattern for the code/json generation:

```yaml
## pattern to applies final variables in the generated json/dart Strings.
## Enclose * in the pattern you need.
## {*} = {{name}} becomes {name}
## %* = {{name}} becomes %name
## (*) = {{name}} becomes (name)
## - Special case when you need * as prefix or suffix, use *? as splitter
## ***?** = {{name}} becomes **name**
param_output_pattern: "{{*}}"
```

⚠️ **Warning**:
> Do not confuse the data source placeholder format with `param_output_pattern` configuration.
Data-source (your yaml strings) must have this form `{{variable}}` to be interpreted as variables.
The generated output strings uses `param_output_pattern` configuration to render the variables as you please.

### Utilities:

- `fts extract [--path] [--output]`: This tiny utility command performs a shallow search (no syslinks) of your dart classes and uses a basic pattern matching to capture your code's Strings.
Might come in handy when you wanna localize an app with hardcoded texts. It only process '.dart' files, and the String matching isn't very permissive (single words Strings are skipped).
Pass the folder to analyse in `--path` and the folder (or json file) path to save in `--output`.
It will output a single json file cloning the structure of the source code folder tree for easy manual search.
It's up to you to clean it up, adjust keys, split it up in other data source files, and USE it with "Flutter Translate Sheet".
This command tool is in alpha state, but don't worry, as it doesn't touch any of analyzed files, so is safe.

It captures interpolated strings in your dart code, variables like `$name`, or `${obj.friends.length}`, and use them as placeholders:
`$name` becomes `{{name}}` and  `${obj.friends.length}`  becomes `{{length}}`.

- New options added: [-s] captures all Strings (event without spaces), 
and [-e] allows you to define a comma separated list of file extensions to search for Strings, like `-e dart,java,kt,arb`

Also... when you specify an --output that ends with `.yaml`, you will have a pretty cool template to plug into `fts run` :)


- If you run the cli on macos, `fts` keeps your [iOS app bundle](https://flutter.dev/docs/development/accessibility-and-localization/internationalization#localizing-for-ios-updating-the-ios-app-bundle) synced automatically with the locales! One thing less to worry about.

### arb and Intl:

We have an experimental support for arb generation. In config.yaml just set (or create if it doesnt exists) this field.
(This tag will soon be changed to something more "generic" as arb output).

```yaml
intl:
  enabled: true
```


Example of .arb readable metadata:
```yaml
  today: "Today is {{date}}, and is hot."
  "@today":
    description: Show today's message with temperature.
    placeholders:
      date:
        type: DateTime
        format: yMMMEd
 ```

For plurals, we have a custom way of writing the dictionary. Just use `plural:variableName:` so `fts` knows how to generate the String.
Remember that `other` is mandatory (the default value) when you use plurals. 

Raw way of adding the metadata: 
```yaml
  ### not required, but you will be a much cooler dev if you provide context :)
  "@messageCount":
    {
      "description": "New messages count on the Home screen",
      "placeholders": { "count": {} },
    }

  messageCount:
    plural:count:
      =0: No new messages
      =1: You have 1 new message
      =2: You have a couple of messages
      other: You have {{count}} new messages
```

Previous yaml will output in *lib/l10n/app_en.arb* (or the path you defined in arb-dir inside l10n.yaml) :
`"messageCount": "{count,plural, =0{No new messages}=1{You have 1 new message}=2{You have a couple of messages}other{You have {count} new messages}}",` 

Now you can also capture internal variables in the plural/selector modifiers, and add the type and parsing information into it!  
```yaml
messageCount:
    plural:count:
      =0: No new messages
      =1: You have 1 new message. You won {{money:int:compactCurrency(decimalDigits:2,name:"Euro",symbol:"€")}}, congratulations!
      =2: You have a couple of messages
      other: You have {{count:int}} new messages
```

All {{variables}} supports this special way to define name, type, format, arguments.
Useful when you don't want to use the @meta arb approach.

The "format" part applies to [NumberFormatter](https://api.flutter.dev/flutter/intl/NumberFormat-class.html) and [DateFormat](https://api.flutter.dev/flutter/intl/DateFormat-class.html) constructors.
`{{variable:Type:Format(OptionalNamedArguments)}}` 


Selectors (like gender), are also included for the arb generation, although not yet supported on intl for code generation:
```yaml
roleWelcome:
  selector:role:
    admin: Hi admin!
    manager: Hi manager!
    other: Hi visitor.
```
output arb:
```arb
"mainRoleWelcome": "{role, select, admin {Hi admin!} manager {Hi manager!} other {Hi visitor.} }",
"@mainRoleWelcome": {
    "description": "Auto-generated for mainRoleWelcome",
    "placeholders": {
        "role": {
            "type": "String"
        }
    }
}
```

### 📝 Utilities:

You can use `SimpleLangPicker()` widget when you generate the dart code (included by default in `TData class]).
Is meant to be a quick tester to change languages. For example, if you use GetX for translations:
```dart
return Scaffold(
  appBar: AppBar(
    title: Text(widget.title),
    actions: [
      SimpleLangPicker(
        onSelected: Get.updateLocale,
        selected: Get.locale,
      ),
    ],
  ),
  ...
```

We will try to provide a richer experience integrating more libraries outputs in the future.  

### 📝 Considerations:

- Is preferable to keep the *trconfig.yaml* in the root of your project, some commands assumes that location (like arb generation).  

- When using arb output, make sure you have *l10n.yaml* next to the *trconfig.yaml* at the root of your project.

- In your spreadsheet, the first column will always be your "keys", don't change that, don't move the column.

- In your *trconfig.yaml*, the first locale you define is your **master** language:

```yaml
locales:
  - es ## master language used in `entry_file`
  - en ## language list to translate.
  - ko
```

- The tool only analyzes the locales in your config... will not keep updated any other sheet column with other locales.

- You can move the columns, or add new columns, around as long as the `keys` is always the first (*A1*).

- The 1st ROW in your sheet are the "headers", don't change the autogenerated names.

- If *fts* finds the 2nd ROW empty in any column, it will take the data corrupted, and will re-upload for translation.

- If the row count from keys is different from the master language, it will invalidate the entire sheet.


----

Thanks for passing by!


![](https://estruyf-github.azurewebsites.net/api/VisitorHit?user=roipeker&repo=flutter_translation_sheet&countColorcountColor&countColor=%23323232)
## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://github.com/IsmailAlamKhan"><img src="https://avatars.githubusercontent.com/u/67656229?v=4?s=100" width="100px;" alt=""/><br /><sub><b>IsmailAlamKhan</b></sub></a><br /><a href="#maintenance-IsmailAlamKhan" title="Maintenance">🚧</a> <a href="https://github.com/roipeker/flutter_translation_sheet/commits?author=IsmailAlamKhan" title="Code">💻</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!