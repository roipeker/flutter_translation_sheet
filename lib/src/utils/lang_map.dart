import 'package:flutter_translation_sheet/src/utils/utils.dart';

/// Resolve Locale information [LangInfo] through the locale key (es, en).
/// Instead of null, if languageCode not found, returns an empty [LangInfo]
LangInfo langInfoFromKey(String key) {
  key = normLocale(key, '-').toLowerCase();
  // key = key.replaceAll('_', '-');
  if (!kLangMap.containsKey(key)) {
    print('Language code not found: $key');
    return LangInfo(
      '',
      '',
      key,
    );
  }
  final vo = kLangMap[key]!;
  return LangInfo(
    vo['nativeName']!,
    vo['englishName']!,
    key,
  );
}

/// Class to extend Locale information with nativeName, englishName and key,
class LangInfo {
  final String nativeName, englishName, key;

  LangInfo(this.nativeName, this.englishName, this.key);

  @override
  String toString() => '$key - $englishName ($nativeName)';
}

/// Glossary of the available locales with their native names and english names.
const kLangMap = <String, Map<String, String>>{
  'ach': {'nativeName': 'Lwo', 'englishName': 'Acholi'},
  'ady': {'nativeName': 'Адыгэбзэ', 'englishName': 'Adyghe'},
  'af': {'nativeName': 'Afrikaans', 'englishName': 'Afrikaans'},
  'af-na': {
    'nativeName': 'Afrikaans (Namibia)',
    'englishName': 'Afrikaans (Namibia)'
  },
  'af-za': {
    'nativeName': 'Afrikaans (South Africa)',
    'englishName': 'Afrikaans (South Africa)'
  },
  'ak': {'nativeName': 'Tɕɥi', 'englishName': 'Akan'},
  'ar': {'nativeName': 'العربية', 'englishName': 'Arabic'},
  'ar-ar': {'nativeName': 'العربية', 'englishName': 'Arabic'},
  'ar-ma': {'nativeName': 'العربية', 'englishName': 'Arabic (Morocco)'},
  'ar-sa': {
    'nativeName': 'العربية (السعودية)',
    'englishName': 'Arabic (Saudi Arabia)'
  },
  'ay-bo': {'nativeName': 'Aymar aru', 'englishName': 'Aymara'},
  'az': {'nativeName': 'Azərbaycan dili', 'englishName': 'Azerbaijani'},
  'az-az': {'nativeName': 'Azərbaycan dili', 'englishName': 'Azerbaijani'},
  'be-by': {'nativeName': 'Беларуская', 'englishName': 'Belarusian'},
  'bg': {'nativeName': 'Български', 'englishName': 'Bulgarian'},
  'bg-bg': {'nativeName': 'Български', 'englishName': 'Bulgarian'},
  'bn': {'nativeName': 'বাংলা', 'englishName': 'Bengali'},
  'bn-in': {'nativeName': 'বাংলা (ভারত)', 'englishName': 'Bengali (India)'},
  'bn-bd': {
    'nativeName': 'বাংলা(বাংলাদেশ)',
    'englishName': 'Bengali (Bangladesh)'
  },
  'br': {'nativeName': 'Brezhoneg', 'englishName': 'Breton'},
  'bs-ba': {'nativeName': 'Bosanski', 'englishName': 'Bosnian'},
  'ca': {'nativeName': 'Català', 'englishName': 'Catalan'},
  'ca-es': {'nativeName': 'Català', 'englishName': 'Catalan'},
  'cak': {'nativeName': 'Maya Kaqchikel', 'englishName': 'Kaqchikel'},
  'ck-us': {'nativeName': 'ᏣᎳᎩ (tsalagi)', 'englishName': 'Cherokee'},
  'cs': {'nativeName': 'Čeština', 'englishName': 'Czech'},
  'cs-cz': {'nativeName': 'Čeština', 'englishName': 'Czech'},
  'cy': {'nativeName': 'Cymraeg', 'englishName': 'Welsh'},
  'cy-gb': {'nativeName': 'Cymraeg', 'englishName': 'Welsh'},
  'da': {'nativeName': 'Dansk', 'englishName': 'Danish'},
  'da-dk': {'nativeName': 'Dansk', 'englishName': 'Danish'},
  'de': {'nativeName': 'Deutsch', 'englishName': 'German'},
  'de-at': {
    'nativeName': 'Deutsch (Österreich)',
    'englishName': 'German (Austria)'
  },
  'de-de': {
    'nativeName': 'Deutsch (Deutschland)',
    'englishName': 'German (Germany)'
  },
  'de-ch': {
    'nativeName': 'Deutsch (Schweiz)',
    'englishName': 'German (Switzerland)'
  },
  'dsb': {'nativeName': 'Dolnoserbšćina', 'englishName': 'Lower Sorbian'},
  'el': {'nativeName': 'Ελληνικά', 'englishName': 'Greek'},
  'el-gr': {'nativeName': 'Ελληνικά', 'englishName': 'Greek (Greece)'},
  'en': {'nativeName': 'English', 'englishName': 'English'},
  'en-gb': {'nativeName': 'English (UK)', 'englishName': 'English (UK)'},
  'en-au': {
    'nativeName': 'English (Australia)',
    'englishName': 'English (Australia)'
  },
  'en-ca': {
    'nativeName': 'English (Canada)',
    'englishName': 'English (Canada)'
  },
  'en-ie': {
    'nativeName': 'English (Ireland)',
    'englishName': 'English (Ireland)'
  },
  'en-in': {'nativeName': 'English (India)', 'englishName': 'English (India)'},
  'en-pi': {
    'nativeName': 'English (Pirate)',
    'englishName': 'English (Pirate)'
  },
  'en-ud': {
    'nativeName': 'English (Upside Down)',
    'englishName': 'English (Upside Down)'
  },
  'en-us': {'nativeName': 'English (US)', 'englishName': 'English (US)'},
  'en-za': {
    'nativeName': 'English (South Africa)',
    'englishName': 'English (South Africa)'
  },
  'en@pirate': {
    'nativeName': 'English (Pirate)',
    'englishName': 'English (Pirate)'
  },
  'eo': {'nativeName': 'Esperanto', 'englishName': 'Esperanto'},
  'eo-eo': {'nativeName': 'Esperanto', 'englishName': 'Esperanto'},
  'es': {'nativeName': 'Español', 'englishName': 'Spanish'},
  'es-ar': {
    'nativeName': 'Español (Argentine)',
    'englishName': 'Spanish (Argentina)'
  },
  'es-419': {
    'nativeName': 'Español (Latinoamérica)',
    'englishName': 'Spanish (Latin America)'
  },
  'es-cl': {'nativeName': 'Español (Chile)', 'englishName': 'Spanish (Chile)'},
  'es-co': {
    'nativeName': 'Español (Colombia)',
    'englishName': 'Spanish (Colombia)'
  },
  'es-ec': {
    'nativeName': 'Español (Ecuador)',
    'englishName': 'Spanish (Ecuador)'
  },
  'es-es': {'nativeName': 'Español (España)', 'englishName': 'Spanish (Spain)'},
  'es-la': {
    'nativeName': 'Español (Latinoamérica)',
    'englishName': 'Spanish (Latin America)'
  },
  'es-ni': {
    'nativeName': 'Español (Nicaragua)',
    'englishName': 'Spanish (Nicaragua)'
  },
  'es-mx': {
    'nativeName': 'Español (México)',
    'englishName': 'Spanish (Mexico)'
  },
  'es-us': {
    'nativeName': 'Español (Estados Unidos)',
    'englishName': 'Spanish (United States)'
  },
  'es-ve': {
    'nativeName': 'Español (Venezuela)',
    'englishName': 'Spanish (Venezuela)'
  },
  'et': {'nativeName': 'eesti keel', 'englishName': 'Estonian'},
  'et-ee': {
    'nativeName': 'Eesti (Estonia)',
    'englishName': 'Estonian (Estonia)'
  },
  'eu': {'nativeName': 'Euskara', 'englishName': 'Basque'},
  'eu-es': {'nativeName': 'Euskara', 'englishName': 'Basque'},
  'fa': {'nativeName': 'فارسی', 'englishName': 'Persian'},
  'fa-ir': {'nativeName': 'فارسی', 'englishName': 'Persian'},
  'fb-lt': {'nativeName': 'Leet Speak', 'englishName': 'Leet'},
  'ff': {'nativeName': 'Fulah', 'englishName': 'Fulah'},
  'fi': {'nativeName': 'Suomi', 'englishName': 'Finnish'},
  'fi-fi': {'nativeName': 'Suomi', 'englishName': 'Finnish'},
  'fo-fo': {'nativeName': 'Føroyskt', 'englishName': 'Faroese'},
  'fr': {'nativeName': 'Français', 'englishName': 'French'},
  'fr-ca': {
    'nativeName': 'Français (Canada)',
    'englishName': 'French (Canada)'
  },
  'fr-fr': {
    'nativeName': 'Français (France)',
    'englishName': 'French (France)'
  },
  'fr-be': {
    'nativeName': 'Français (Belgique)',
    'englishName': 'French (Belgium)'
  },
  'fr-ch': {
    'nativeName': 'Français (Suisse)',
    'englishName': 'French (Switzerland)'
  },
  'fy-nl': {'nativeName': 'Frysk', 'englishName': 'Frisian (West)'},
  'ga': {'nativeName': 'Gaeilge', 'englishName': 'Irish'},
  'ga-ie': {'nativeName': 'Gaeilge', 'englishName': 'Irish'},
  'gd': {'nativeName': 'Gàidhlig', 'englishName': 'Gaelic'},
  'gl': {'nativeName': 'Galego', 'englishName': 'Galician'},
  'gl-es': {'nativeName': 'Galego', 'englishName': 'Galician'},
  'gn-py': {'nativeName': 'Avañe\'ẽ', 'englishName': 'Guarani'},
  'gu-in': {'nativeName': 'ગુજરાતી', 'englishName': 'Gujarati'},
  'gv': {'nativeName': 'Gaelg', 'englishName': 'Manx'},
  'gx-gr': {'nativeName': 'Ἑλληνική ἀρχαία', 'englishName': 'Classical Greek'},
  'he': {'nativeName': 'עברית‏', 'englishName': 'Hebrew'},
  'he-il': {'nativeName': 'עברית‏', 'englishName': 'Hebrew'},
  'hi': {'nativeName': 'हिन्दी', 'englishName': 'Hindi'},
  'hi-in': {'nativeName': 'हिन्दी', 'englishName': 'Hindi'},
  'hr': {'nativeName': 'Hrvatski', 'englishName': 'Croatian'},
  'hr-hr': {'nativeName': 'Hrvatski', 'englishName': 'Croatian'},
  'hsb': {'nativeName': 'Hornjoserbšćina', 'englishName': 'Upper Sorbian'},
  'ht': {'nativeName': 'Kreyòl', 'englishName': 'Haitian Creole'},
  'hu': {'nativeName': 'Magyar', 'englishName': 'Hungarian'},
  'hu-hu': {'nativeName': 'Magyar', 'englishName': 'Hungarian'},
  'hy-am': {'nativeName': 'Հայերեն', 'englishName': 'Armenian'},
  'id': {'nativeName': 'Bahasa Indonesia', 'englishName': 'Indonesian'},
  'id-id': {'nativeName': 'Bahasa Indonesia', 'englishName': 'Indonesian'},
  'is': {'nativeName': 'Íslenska', 'englishName': 'Icelandic'},
  'is-is': {
    'nativeName': 'Íslenska (Iceland)',
    'englishName': 'Icelandic (Iceland)'
  },
  'it': {'nativeName': 'Italiano', 'englishName': 'Italian'},
  'it-it': {'nativeName': 'Italiano', 'englishName': 'Italian'},
  'ja': {'nativeName': '日本語', 'englishName': 'Japanese'},
  'ja-jp': {'nativeName': '日本語 (日本)', 'englishName': 'Japanese (Japan)'},
  'jv-id': {'nativeName': 'Basa Jawa', 'englishName': 'Javanese'},
  'ka': {'nativeName': 'ქართული', 'englishName': 'Georgian'},
  'ka-ge': {'nativeName': 'ქართული', 'englishName': 'Georgian'},
  'kk-kz': {'nativeName': 'Қазақша', 'englishName': 'Kazakh'},
  'km': {'nativeName': 'ភាសាខ្មែរ', 'englishName': 'Khmer'},
  'km-kh': {'nativeName': 'ភាសាខ្មែរ', 'englishName': 'Khmer'},
  'kab': {'nativeName': 'Taqbaylit', 'englishName': 'Kabyle'},
  'kn': {'nativeName': 'ಕನ್ನಡ', 'englishName': 'Kannada'},
  'kn-in': {'nativeName': 'ಕನ್ನಡ (India)', 'englishName': 'Kannada (India)'},
  'ko': {'nativeName': '한국어', 'englishName': 'Korean'},
  'ko-kr': {'nativeName': '한국어 (한국)', 'englishName': 'Korean (Korea)'},
  'ku-tr': {'nativeName': 'Kurdî', 'englishName': 'Kurdish'},
  'kw': {'nativeName': 'Kernewek', 'englishName': 'Cornish'},
  'la': {'nativeName': 'Latin', 'englishName': 'Latin'},
  'la-va': {'nativeName': 'Latin', 'englishName': 'Latin'},
  'lb': {'nativeName': 'Lëtzebuergesch', 'englishName': 'Luxembourgish'},
  'li-nl': {'nativeName': 'Lèmbörgs', 'englishName': 'Limburgish'},
  'lt': {'nativeName': 'Lietuvių', 'englishName': 'Lithuanian'},
  'lt-lt': {'nativeName': 'Lietuvių', 'englishName': 'Lithuanian'},
  'lv': {'nativeName': 'Latviešu', 'englishName': 'Latvian'},
  'lv-lv': {'nativeName': 'Latviešu', 'englishName': 'Latvian'},
  'mai': {'nativeName': 'मैथिली, মৈথিলী', 'englishName': 'Maithili'},
  'mg-mg': {'nativeName': 'Malagasy', 'englishName': 'Malagasy'},
  'mk': {'nativeName': 'Македонски', 'englishName': 'Macedonian'},
  'mk-mk': {
    'nativeName': 'Македонски (Македонски)',
    'englishName': 'Macedonian (Macedonian)'
  },
  'ml': {'nativeName': 'മലയാളം', 'englishName': 'Malayalam'},
  'ml-in': {'nativeName': 'മലയാളം', 'englishName': 'Malayalam'},
  'mn-mn': {'nativeName': 'Монгол', 'englishName': 'Mongolian'},
  'mr': {'nativeName': 'मराठी', 'englishName': 'Marathi'},
  'mr-in': {'nativeName': 'मराठी', 'englishName': 'Marathi'},
  'ms': {'nativeName': 'Bahasa Melayu', 'englishName': 'Malay'},
  'ms-my': {'nativeName': 'Bahasa Melayu', 'englishName': 'Malay'},
  'mt': {'nativeName': 'Malti', 'englishName': 'Maltese'},
  'mt-mt': {'nativeName': 'Malti', 'englishName': 'Maltese'},
  'my': {'nativeName': 'ဗမာစကာ', 'englishName': 'Burmese'},
  'no': {'nativeName': 'Norsk', 'englishName': 'Norwegian'},
  'nb': {'nativeName': 'Norsk (bokmål)', 'englishName': 'Norwegian (bokmal)'},
  'nb-no': {
    'nativeName': 'Norsk (bokmål)',
    'englishName': 'Norwegian (bokmal)'
  },
  'ne': {'nativeName': 'नेपाली', 'englishName': 'Nepali'},
  'ne-np': {'nativeName': 'नेपाली', 'englishName': 'Nepali'},
  'nl': {'nativeName': 'Nederlands', 'englishName': 'Dutch'},
  'nl-be': {
    'nativeName': 'Nederlands (België)',
    'englishName': 'Dutch (Belgium)'
  },
  'nl-nl': {
    'nativeName': 'Nederlands (Nederland)',
    'englishName': 'Dutch (Netherlands)'
  },
  'nn-no': {
    'nativeName': 'Norsk (nynorsk)',
    'englishName': 'Norwegian (nynorsk)'
  },
  'oc': {'nativeName': 'Occitan', 'englishName': 'Occitan'},
  'or-in': {'nativeName': 'ଓଡ଼ିଆ', 'englishName': 'Oriya'},
  'pa': {'nativeName': 'ਪੰਜਾਬੀ', 'englishName': 'Punjabi'},
  'pa-in': {
    'nativeName': 'ਪੰਜਾਬੀ (ਭਾਰਤ ਨੂੰ)',
    'englishName': 'Punjabi (India)'
  },
  'pl': {'nativeName': 'Polski', 'englishName': 'Polish'},
  'pl-pl': {'nativeName': 'Polski', 'englishName': 'Polish'},
  'ps-af': {'nativeName': 'پښتو', 'englishName': 'Pashto'},
  'pt': {'nativeName': 'Português', 'englishName': 'Portuguese'},
  'pt-br': {
    'nativeName': 'Português (Brasil)',
    'englishName': 'Portuguese (Brazil)'
  },
  'pt-pt': {
    'nativeName': 'Português (Portugal)',
    'englishName': 'Portuguese (Portugal)'
  },
  'qu-pe': {'nativeName': 'Qhichwa', 'englishName': 'Quechua'},
  'rm-ch': {'nativeName': 'Rumantsch', 'englishName': 'Romansh'},
  'ro': {'nativeName': 'Română', 'englishName': 'Romanian'},
  'ro-ro': {'nativeName': 'Română', 'englishName': 'Romanian'},
  'ru': {'nativeName': 'Русский', 'englishName': 'Russian'},
  'ru-ru': {'nativeName': 'Русский', 'englishName': 'Russian'},
  'sa-in': {'nativeName': 'संस्कृतम्', 'englishName': 'Sanskrit'},
  'se-no': {'nativeName': 'Davvisámegiella', 'englishName': 'Northern Sámi'},
  'sh': {'nativeName': 'српскохрватски', 'englishName': 'Serbo-Croatian'},
  'si-lk': {'nativeName': 'පළාත', 'englishName': 'Sinhala (Sri Lanka)'},
  'sk': {'nativeName': 'Slovenčina', 'englishName': 'Slovak'},
  'sk-sk': {
    'nativeName': 'Slovenčina (Slovakia)',
    'englishName': 'Slovak (Slovakia)'
  },
  'sl': {'nativeName': 'Slovenščina', 'englishName': 'Slovenian'},
  'sl-si': {'nativeName': 'Slovenščina', 'englishName': 'Slovenian'},
  'so-so': {'nativeName': 'Soomaaliga', 'englishName': 'Somali'},
  'sq': {'nativeName': 'Shqip', 'englishName': 'Albanian'},
  'sq-al': {'nativeName': 'Shqip', 'englishName': 'Albanian'},
  'sr': {'nativeName': 'Српски', 'englishName': 'Serbian'},
  'sr-rs': {'nativeName': 'Српски (Serbia)', 'englishName': 'Serbian (Serbia)'},
  'su': {'nativeName': 'Basa Sunda', 'englishName': 'Sundanese'},
  'sv': {'nativeName': 'Svenska', 'englishName': 'Swedish'},
  'sv-se': {'nativeName': 'Svenska', 'englishName': 'Swedish'},
  'sw': {'nativeName': 'Kiswahili', 'englishName': 'Swahili'},
  'sw-ke': {'nativeName': 'Kiswahili', 'englishName': 'Swahili (Kenya)'},
  'ta': {'nativeName': 'தமிழ்', 'englishName': 'Tamil'},
  'ta-in': {'nativeName': 'தமிழ்', 'englishName': 'Tamil'},
  'te': {'nativeName': 'తెలుగు', 'englishName': 'Telugu'},
  'te-in': {'nativeName': 'తెలుగు', 'englishName': 'Telugu'},
  'tg': {'nativeName': 'забо́ни тоҷикӣ́', 'englishName': 'Tajik'},
  'tg-tj': {'nativeName': 'тоҷикӣ', 'englishName': 'Tajik'},
  'th': {'nativeName': 'ภาษาไทย', 'englishName': 'Thai'},
  'th-th': {
    'nativeName': 'ภาษาไทย (ประเทศไทย)',
    'englishName': 'Thai (Thailand)'
  },
  'tl': {'nativeName': 'Filipino', 'englishName': 'Filipino'},
  'tl-ph': {'nativeName': 'Filipino', 'englishName': 'Filipino'},
  'tlh': {'nativeName': 'tlhIngan-Hol', 'englishName': 'Klingon'},
  'tr': {'nativeName': 'Türkçe', 'englishName': 'Turkish'},
  'tr-tr': {'nativeName': 'Türkçe', 'englishName': 'Turkish'},
  'tt-ru': {'nativeName': 'татарча', 'englishName': 'Tatar'},
  'uk': {'nativeName': 'Українська', 'englishName': 'Ukrainian'},
  'uk-ua': {'nativeName': 'Українська', 'englishName': 'Ukrainian'},
  'ur': {'nativeName': 'اردو', 'englishName': 'Urdu'},
  'ur-pk': {'nativeName': 'اردو', 'englishName': 'Urdu'},
  'uz': {'nativeName': 'O\'zbek', 'englishName': 'Uzbek'},
  'uz-uz': {'nativeName': 'O\'zbek', 'englishName': 'Uzbek'},
  'vi': {'nativeName': 'Tiếng Việt', 'englishName': 'Vietnamese'},
  'vi-vn': {'nativeName': 'Tiếng Việt', 'englishName': 'Vietnamese'},
  'xh-za': {'nativeName': 'isiXhosa', 'englishName': 'Xhosa'},
  'yi': {'nativeName': 'ייִדיש', 'englishName': 'Yiddish'},
  'yi-de': {'nativeName': 'ייִדיש (German)', 'englishName': 'Yiddish (German)'},
  'zh': {'nativeName': '中文', 'englishName': 'Chinese'},
  'zh-hans': {'nativeName': '中文简体', 'englishName': 'Chinese Simplified'},
  'zh-hant': {'nativeName': '中文繁體', 'englishName': 'Chinese Traditional'},
  'zh-cn': {
    'nativeName': '中文（中国）',
    'englishName': 'Chinese Simplified (China)'
  },
  'zh-hk': {
    'nativeName': '中文（香港）',
    'englishName': 'Chinese Traditional (Hong Kong)'
  },
  'zh-sg': {
    'nativeName': '中文（新加坡）',
    'englishName': 'Chinese Simplified (Singapore)'
  },
  'zh-tw': {
    'nativeName': '中文（台灣）',
    'englishName': 'Chinese Traditional (Taiwan)'
  },
  'zu-za': {'nativeName': 'isiZulu', 'englishName': 'Zulu'}
};
