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
      '',
    );
  }
  final vo = kLangMap[key]!;
  return LangInfo(
    vo['nativeName']!,
    vo['englishName']!,
    key,
    vo['emoji']!,
  );
}

/// Class to extend Locale information with nativeName, englishName and key,
class LangInfo {
  final String nativeName, englishName, key, emoji;

  LangInfo(this.nativeName, this.englishName, this.key, this.emoji);

  @override
  // String toString() => '$key $emoji  - $englishName ($nativeName)';
  String toString() => '$key - $englishName ($nativeName)';
}

/// Glossary of the available locales with their native names and english names.
const kLangMap = <String, Map<String, String>>{
  'ach': {
    'nativeName': 'Lwo',
    'englishName': 'Acholi',
    'emoji': '🇺🇬',
  },
  'ady': {
    'nativeName': 'Адыгэбзэ',
    'englishName': 'Adyghe',
    'emoji': '🇷🇺',
  },
  'af': {
    'nativeName': 'Afrikaans',
    'englishName': 'Afrikaans',
    'emoji': '🏳',
  },
  'af-na': {
    'nativeName': 'Afrikaans (Namibia)',
    'englishName': 'Afrikaans (Namibia)',
    'emoji': '🇳🇦',
  },
  'af-za': {
    'nativeName': 'Afrikaans (South Africa)',
    'englishName': 'Afrikaans (South Africa)',
    'emoji': '🇿🇦',
  },
  'ak': {
    'nativeName': 'Tɕɥi',
    'englishName': 'Akan',
    'emoji': '🏳',
  },
  'am': {
    'nativeName': 'አማርኛ',
    'englishName': 'Amharic',
    'emoji': '🇪🇹',
  },
  'ar': {
    'nativeName': 'العربية',
    'englishName': 'Arabic',
    'emoji': '🇸🇦',
  },
  'ar-ar': {
    'nativeName': 'العربية',
    'englishName': 'Arabic',
    'emoji': '🇸🇦',
  },
  'ar-ma': {
    'nativeName': 'العربية',
    'englishName': 'Arabic (Morocco)',
    'emoji': '🇲🇦',
  },
  'ar-sa': {
    'nativeName': 'العربية (السعودية)',
    'englishName': 'Arabic (Saudi Arabia)',
    'emoji': '🇸🇦',
  },
  'as': {
    'nativeName': 'অসমীয়া',
    'englishName': 'Assamese',
    'emoji': '🇮🇳',
  },
  'ay-bo': {
    'nativeName': 'Aymar aru',
    'englishName': 'Aymara',
    'emoji': '🇧🇴',
  },
  'ay': {
    'nativeName': 'Aymar aru',
    'englishName': 'Aymara',
    'emoji': '🇧🇴',
  },
  'az': {
    'nativeName': 'Azərbaycan dili',
    'englishName': 'Azerbaijani',
    'emoji': '🇦🇿',
  },
  'az-az': {
    'nativeName': 'Azərbaycan dili',
    'englishName': 'Azerbaijani',
    'emoji': '🇦🇿',
  },
  'bm': {
    'nativeName': 'بامبارا',
    'englishName': 'Bambara',
    'emoji': '🇲🇱',
  },
  'be-by': {
    'nativeName': 'Беларуская',
    'englishName': 'Belarusian',
    'emoji': '🇧🇾',
  },
  'be': {
    'nativeName': 'Беларуская',
    'englishName': 'Belarusian',
    'emoji': '🇧🇾',
  },
  'bg': {
    'nativeName': 'Български',
    'englishName': 'Bulgarian',
    'emoji': '🇧🇬',
  },
  'bg-bg': {
    'nativeName': 'Български',
    'englishName': 'Bulgarian',
    'emoji': '🇧🇬',
  },
  'bn': {
    'nativeName': 'বাংলা',
    'englishName': 'Bengali',
    'emoji': '🇧🇩',
  },
  'bn-in': {
    'nativeName': 'বাংলা (ভারত)',
    'englishName': 'Bengali (India)',
    'emoji': '🇮🇳',
  },
  'bn-bd': {
    'nativeName': 'বাংলা(বাংলাদেশ)',
    'englishName': 'Bengali (Bangladesh)',
    'emoji': '🇧🇩',
  },
  'bho': {
    'nativeName': 'भोजपुरी',
    'englishName': 'Bhojpuri',
    'emoji': '🇮🇳',
  },
  'br': {
    'nativeName': 'Brezhoneg',
    'englishName': 'Breton',
    'emoji': '🇫🇷',
  },
  'bs-ba': {
    'nativeName': 'Bosanski',
    'englishName': 'Bosnian',
    'emoji': '🇧🇦',
  },
  'bs': {
    'nativeName': 'Bosanski',
    'englishName': 'Bosnian',
    'emoji': '🇧🇦',
  },
  'ca': {
    'nativeName': 'Català',
    'englishName': 'Catalan',
    'emoji': '🇪🇸',
  },
  'ca-es': {
    'nativeName': 'Català',
    'englishName': 'Catalan',
    'emoji': '🇪🇸',
  },
  'cak': {
    'nativeName': 'Maya Kaqchikel',
    'englishName': 'Kaqchikel',
    'emoji': '🇬🇹',
  },
  'ceb': {
    'nativeName': 'Sugbuanon',
    'englishName': 'Cebuano',
    'emoji': '🇵🇭',
  },
  'ck-us': {
    'nativeName': 'ᏣᎳᎩ (tsalagi)',
    'englishName': 'Cherokee',
    'emoji': '🇺🇸',
  },
  'co': {
    'nativeName': 'corsu',
    'englishName': 'Corsican',
    'emoji': '🇫🇷',
  },
  'cs': {
    'nativeName': 'Čeština',
    'englishName': 'Czech',
    'emoji': '🇨🇿',
  },
  'cs-cz': {
    'nativeName': 'Čeština',
    'englishName': 'Czech',
    'emoji': '🇨🇿',
  },
  'cy': {
    'nativeName': 'Cymraeg',
    'englishName': 'Welsh',
    'emoji': '🏳',
  },
  'cy-gb': {
    'nativeName': 'Cymraeg',
    'englishName': 'Welsh',
    'emoji': '🇬🇧',
  },
  'da': {
    'nativeName': 'Dansk',
    'englishName': 'Danish',
    'emoji': '🇩🇰',
  },
  'da-dk': {
    'nativeName': 'Dansk',
    'englishName': 'Danish',
    'emoji': '🇩🇰',
  },
  'de': {
    'nativeName': 'Deutsch',
    'englishName': 'German',
    'emoji': '🇩🇪',
  },
  'de-at': {
    'nativeName': 'Deutsch (Österreich)',
    'englishName': 'German (Austria)',
    'emoji': '🇦🇹',
  },
  'de-de': {
    'nativeName': 'Deutsch (Deutschland)',
    'englishName': 'German (Germany)',
    'emoji': '🇩🇪',
  },
  'de-ch': {
    'nativeName': 'Deutsch (Schweiz)',
    'englishName': 'German (Switzerland)',
    'emoji': '🇨🇭',
  },
  'dsb': {
    'nativeName': 'Dolnoserbšćina',
    'englishName': 'Lower Sorbian',
    'emoji': '🏳',
  },
  'dv': {
    'nativeName': 'ދިވެހި',
    'englishName': 'Dhivehi',
    'emoji': '🇮🇳',
  },
  'doi': {
    'nativeName': 'डोगरी',
    'englishName': 'Dogri',
    'emoji': '🇮🇳',
  },
  'ee': {
    'nativeName': 'Ewe',
    'englishName': 'Ewe',
    'emoji': '🏳',
  },
  'el': {
    'nativeName': 'Ελληνικά',
    'englishName': 'Greek',
    'emoji': '🇬🇷',
  },
  'el-gr': {
    'nativeName': 'Ελληνικά',
    'englishName': 'Greek (Greece)',
    'emoji': '🇬🇷',
  },
  'en': {
    'nativeName': 'English',
    'englishName': 'English',
    'emoji': '🇬🇧',
  },
  'en-gb': {
    'nativeName': 'English (UK)',
    'englishName': 'English (UK)',
    'emoji': '🇬🇧',
  },
  'en-au': {
    'nativeName': 'English (Australia)',
    'englishName': 'English (Australia)',
    'emoji': '🇦🇺',
  },
  'en-ca': {
    'nativeName': 'English (Canada)',
    'englishName': 'English (Canada)',
    'emoji': '🇨🇦',
  },
  'en-ie': {
    'nativeName': 'English (Ireland)',
    'englishName': 'English (Ireland)',
    'emoji': '🇮🇪',
  },
  'en-in': {
    'nativeName': 'English (India)',
    'englishName': 'English (India)',
    'emoji': '🇮🇳',
  },
  'en-pi': {
    'nativeName': 'English (Pirate)',
    'englishName': 'English (Pirate)',
    'emoji': '🇺🇸',
  },
  'en-ud': {
    'nativeName': 'English (Upside Down)',
    'englishName': 'English (Upside Down)',
    'emoji': '🇺🇸',
  },
  'en-us': {
    'nativeName': 'English (US)',
    'englishName': 'English (US)',
    'emoji': '🇺🇸',
  },
  'en-za': {
    'nativeName': 'English (South Africa)',
    'englishName': 'English (South Africa)',
    'emoji': '🇿🇦',
  },
  'en@pirate': {
    'nativeName': 'English (Pirate)',
    'englishName': 'English (Pirate)',
    'emoji': '🏴󠁧󠁢󠁥󠁮󠁧󠁿',
  },
  'eo': {
    'nativeName': 'Esperanto',
    'englishName': 'Esperanto',
    'emoji': '🏳',
  },
  'eo-eo': {
    'nativeName': 'Esperanto',
    'englishName': 'Esperanto',
    'emoji': '🏳',
  },
  'es': {
    'nativeName': 'Español',
    'englishName': 'Spanish',
    'emoji': '🇪🇸',
  },
  'es-ar': {
    'nativeName': 'Español (Argentine)',
    'englishName': 'Spanish (Argentina)',
    'emoji': '🇦🇷',
  },
  'es-419': {
    'nativeName': 'Español (Latinoamérica)',
    'englishName': 'Spanish (Latin America)',
    'emoji': '🏳',
  },
  'es-cl': {
    'nativeName': 'Español (Chile)',
    'englishName': 'Spanish (Chile)',
    'emoji': '🇨🇱',
  },
  'es-co': {
    'nativeName': 'Español (Colombia)',
    'englishName': 'Spanish (Colombia)',
    'emoji': '🇨🇴',
  },
  'es-ec': {
    'nativeName': 'Español (Ecuador)',
    'englishName': 'Spanish (Ecuador)',
    'emoji': '🇪🇨',
  },
  'es-es': {
    'nativeName': 'Español (España)',
    'englishName': 'Spanish (Spain)',
    'emoji': '🇪🇸',
  },
  'es-la': {
    'nativeName': 'Español (Latinoamérica)',
    'englishName': 'Spanish (Latin America)',
    'emoji': '🏳',
  },
  'es-ni': {
    'nativeName': 'Español (Nicaragua)',
    'englishName': 'Spanish (Nicaragua)',
    'emoji': '🇳🇮',
  },
  'es-mx': {
    'nativeName': 'Español (México)',
    'englishName': 'Spanish (Mexico)',
    'emoji': '🇲🇽',
  },
  'es-us': {
    'nativeName': 'Español (Estados Unidos)',
    'englishName': 'Spanish (United States)',
    'emoji': '🇺🇸',
  },
  'es-ve': {
    'nativeName': 'Español (Venezuela)',
    'englishName': 'Spanish (Venezuela)',
    'emoji': '🇻🇪',
  },
  'et': {
    'nativeName': 'eesti keel',
    'englishName': 'Estonian',
    'emoji': '🇪🇪',
  },
  'et-ee': {
    'nativeName': 'Eesti (Estonia)',
    'englishName': 'Estonian (Estonia)',
    'emoji': '🇪🇪',
  },
  'eu': {
    'nativeName': 'Euskara',
    'englishName': 'Basque',
    'emoji': '🇪🇸',
  },
  'eu-es': {
    'nativeName': 'Euskara',
    'englishName': 'Basque',
    'emoji': '🇪🇸',
  },
  'fa': {
    'nativeName': 'فارسی',
    'englishName': 'Persian',
    'emoji': '🇮🇷',
  },
  'fa-ir': {
    'nativeName': 'فارسی',
    'englishName': 'Persian',
    'emoji': '🇮🇷',
  },
  'fb-lt': {
    'nativeName': 'Leet Speak',
    'englishName': 'Leet',
    'emoji': '🇱🇹',
  },
  'ff': {
    'nativeName': 'Fulah',
    'englishName': 'Fulah',
    'emoji': '🏳',
  },
  'fi': {
    'nativeName': 'Suomi',
    'englishName': 'Finnish',
    'emoji': '🇫🇮',
  },
  'fi-fi': {
    'nativeName': 'Suomi',
    'englishName': 'Finnish',
    'emoji': '🇫🇮',
  },
  'fo-fo': {
    'nativeName': 'Føroyskt',
    'englishName': 'Faroese',
    'emoji': '🇫🇴',
  },
  'fr': {
    'nativeName': 'Français',
    'englishName': 'French',
    'emoji': '🇫🇷',
  },
  'fr-ca': {
    'nativeName': 'Français (Canada)',
    'englishName': 'French (Canada)',
    'emoji': '🇨🇦',
  },
  'fr-fr': {
    'nativeName': 'Français (France)',
    'englishName': 'French (France)',
    'emoji': '🇫🇷',
  },
  'fr-be': {
    'nativeName': 'Français (Belgique)',
    'englishName': 'French (Belgium)',
    'emoji': '🇧🇪',
  },
  'fr-ch': {
    'nativeName': 'Français (Suisse)',
    'englishName': 'French (Switzerland)',
    'emoji': '🇨🇭',
  },
  'fy-nl': {
    'nativeName': 'Frysk',
    'englishName': 'Frisian (West)',
    'emoji': '🇳🇱',
  },
  'ga': {
    'nativeName': 'Gaeilge',
    'englishName': 'Irish',
    'emoji': '🇮🇪',
  },
  'ga-ie': {
    'nativeName': 'Gaeilge',
    'englishName': 'Irish',
    'emoji': '🇮🇪',
  },
  'gd': {
    'nativeName': 'Gàidhlig',
    'englishName': 'Gaelic',
    'emoji': '🇬🇧',
  },
  'st': {
    'nativeName': 'Sotho',
    'englishName': 'Sesotho',
    'emoji': '🇿🇦',
  },
  'sn': {
    'nativeName': 'chiShona',
    'englishName': 'Shona',
    'emoji': '🇿🇼',
  },
  'sd': {
    'nativeName': 'سنڌي',
    'englishName': 'Sindhi',
    'emoji': '🇮🇳',
  },
  'si': {
    'nativeName': 'සිංහල',
    'englishName': 'Sinhala',
    'emoji': '🇱🇰',
  },
  'nso': {
    'nativeName': 'Pedi',
    'englishName': 'Sepedi',
    'emoji': '🇿🇦',
  },
  'gl': {
    'nativeName': 'Galego',
    'englishName': 'Galician',
    'emoji': '🇪🇸',
  },
  'gl-es': {
    'nativeName': 'Galego',
    'englishName': 'Galician',
    'emoji': '🇪🇸',
  },
  'gn-py': {
    'nativeName': 'Avañe\'ẽ',
    'englishName': 'Guarani',
    'emoji': '🇵🇾',
  },
  'gu-in': {
    'nativeName': 'ગુજરાતી',
    'englishName': 'Gujarati',
    'emoji': '🇮🇳',
  },
  'gv': {
    'nativeName': 'Gaelg',
    'englishName': 'Manx',
    'emoji': '🏳',
  },
  'gx-gr': {
    'nativeName': 'Ἑλληνική ἀρχαία',
    'englishName': 'Classical Greek',
    'emoji': '🇺🇾',
  },
  'ha': {
    'nativeName': 'Hausa',
    'englishName': 'Hausa',
    'emoji': '🏳',
  },
  'haw': {
    'nativeName': 'Hawaiano',
    'englishName': 'Hawaiano',
    'emoji': '🏳',
  },
  'ht': {
    'nativeName': 'Kreyòl ayisyen',
    'englishName': 'Haitian Creole',
    'emoji': '🇭🇹',
  },
  'he': {
    'nativeName': 'עברית‏',
    'englishName': 'Hebrew',
    'emoji': '🇮🇱',
  },
  'he-il': {
    'nativeName': 'עברית‏',
    'englishName': 'Hebrew',
    'emoji': '🇮🇱',
  },
  'iw': {
    'nativeName': 'עברית‏',
    'englishName': 'Hebrew',
    'emoji': '🇮🇱',
  },
  'hi': {
    'nativeName': 'हिन्दी',
    'englishName': 'Hindi',
    'emoji': '🇮🇳',
  },
  'hi-in': {
    'nativeName': 'हिन्दी',
    'englishName': 'Hindi',
    'emoji': '🇮🇳',
  },
  'hmn': {
    'nativeName': 'Hmoob',
    'englishName': 'Hmong',
    'emoji': '🏳',
  },
  'hr': {
    'nativeName': 'Hrvatski',
    'englishName': 'Croatian',
    'emoji': '🇭🇷',
  },
  'hr-hr': {
    'nativeName': 'Hrvatski',
    'englishName': 'Croatian',
    'emoji': '🇭🇷',
  },
  'hsb': {
    'nativeName': 'Hornjoserbšćina',
    'englishName': 'Upper Sorbian',
    'emoji': '🏳',
  },
  'hu': {
    'nativeName': 'Magyar',
    'englishName': 'Hungarian',
    'emoji': '🇭🇺',
  },
  'hu-hu': {
    'nativeName': 'Magyar',
    'englishName': 'Hungarian',
    'emoji': '🇭🇺',
  },
  'hy': {
    'nativeName': 'Հայերեն',
    'englishName': 'Armenian',
    'emoji': '🇦🇲',
  },
  'hy-am': {
    'nativeName': 'Հայերեն',
    'englishName': 'Armenian',
    'emoji': '🇦🇲',
  },
  'id': {
    'nativeName': 'Bahasa Indonesia',
    'englishName': 'Indonesian',
    'emoji': '🇮🇩',
  },
  'id-id': {
    'nativeName': 'Bahasa Indonesia',
    'englishName': 'Indonesian',
    'emoji': '🇮🇩',
  },
  'is': {
    'nativeName': 'Íslenska',
    'englishName': 'Icelandic',
    'emoji': '🇮🇸',
  },
  'is-is': {
    'nativeName': 'Íslenska (Iceland)',
    'englishName': 'Icelandic (Iceland)',
    'emoji': '🇮🇸',
  },
  'ig': {
    'nativeName': 'Ásụ̀sụ́ Ìgbò',
    'englishName': 'Igbo',
    'emoji': '🇳🇬',
  },
  'ilo': {
    'nativeName': 'Iloko',
    'englishName': 'Ilocano',
    'emoji': '🇵🇭',
  },
  'it': {
    'nativeName': 'Italiano',
    'englishName': 'Italian',
    'emoji': '🇮🇹',
  },
  'it-it': {
    'nativeName': 'Italiano',
    'englishName': 'Italian',
    'emoji': '🇮🇹',
  },
  'ja': {
    'nativeName': '日本語',
    'englishName': 'Japanese',
    'emoji': '🇯🇵',
  },
  'ja-jp': {
    'nativeName': '日本語 (日本)',
    'englishName': 'Japanese (Japan)',
    'emoji': '🇯🇵',
  },
  'jv': {
    'nativeName': 'Basa Jawa',
    'englishName': 'Javanese',
    'emoji': '🇮🇩',
  },
  'jw': {
    'nativeName': 'Basa Jawa',
    'englishName': 'Javanese',
    'emoji': '🇮🇩',
  },
  'ka': {
    'nativeName': 'ქართული',
    'englishName': 'Georgian',
    'emoji': '🇬🇪',
  },
  'ka-ge': {
    'nativeName': 'ქართული',
    'englishName': 'Georgian',
    'emoji': '🇬🇪',
  },
  'kk-kz': {
    'nativeName': 'Қазақша',
    'englishName': 'Kazakh',
    'emoji': '🇰🇿',
  },
  'kk': {
    'nativeName': 'Қазақша',
    'englishName': 'Kazakh',
    'emoji': '🇰🇿',
  },
  'km': {
    'nativeName': 'ភាសាខ្មែរ',
    'englishName': 'Khmer',
    'emoji': '🇰🇭',
  },
  'km-kh': {
    'nativeName': 'ភាសាខ្មែរ',
    'englishName': 'Khmer',
    'emoji': '🇰🇭',
  },
  'gom': {
    'nativeName': 'कोंकणी',
    'englishName': 'Konkani',
    'emoji': '🇮🇳',
  },
  'rw': {
    'nativeName': 'Ikinyarwanda',
    'englishName': 'Kinyarwanda',
    'emoji': '🏳',
  },
  'kab': {
    'nativeName': 'Taqbaylit',
    'englishName': 'Kabyle',
    'emoji': '🇩🇿',
  },
  'kn': {
    'nativeName': 'ಕನ್ನಡ',
    'englishName': 'Kannada',
    'emoji': '🇮🇳',
  },
  'kn-in': {
    'nativeName': 'ಕನ್ನಡ (India)',
    'englishName': 'Kannada (India)',
    'emoji': '🇮🇳',
  },
  'ko': {
    'nativeName': '한국어',
    'englishName': 'Korean',
    'emoji': '🇰🇷',
  },
  'ko-kr': {
    'nativeName': '한국어 (한국)',
    'englishName': 'Korean (Korea)',
    'emoji': '🇰🇷',
  },
  'kri': {
    'nativeName': 'Krio',
    'englishName': 'Krio',
    'emoji': '🇸🇱',
  },
  'ku': {
    'nativeName': 'Kurdî',
    'englishName': 'Kurdish',
    'emoji': '🇹🇷',
  },
  'ku-tr': {
    'nativeName': 'Kurdî',
    'englishName': 'Kurdish',
    'emoji': '🇹🇷',
  },
  'ckb': {
    'nativeName': 'سۆرانی',
    'englishName': 'Kurdish (Sorani)',
    'emoji': '🇮🇶',
  },
  'ky': {
    'nativeName': 'Кыргыз тили',
    'englishName': 'Kyrgyz',
    'emoji': '🏳',
  },
  'kw': {
    'nativeName': 'Kernewek',
    'englishName': 'Cornish',
    'emoji': '🇬🇧',
  },
  'la': {
    'nativeName': 'Latin',
    'englishName': 'Latin',
    'emoji': '🏳',
  },
  'lo': {
    'nativeName': 'ພາສາລາວ',
    'englishName': 'Lao',
    'emoji': '🇱🇦',
  },
  'la-va': {
    'nativeName': 'Latin',
    'englishName': 'Latin',
    'emoji': '🇻🇦',
  },
  'lb': {
    'nativeName': 'Lëtzebuergesch',
    'englishName': 'Luxembourgish',
    'emoji': '🇱🇺',
  },
  'li-nl': {
    'nativeName': 'Lèmbörgs',
    'englishName': 'Limburgish',
    'emoji': '🇳🇱',
  },
  'lt': {
    'nativeName': 'Lietuvių',
    'englishName': 'Lithuanian',
    'emoji': '🇱🇹',
  },
  'lt-lt': {
    'nativeName': 'Lietuvių',
    'englishName': 'Lithuanian',
    'emoji': '🇱🇹',
  },
  'lg': {
    'nativeName': 'Oluganda',
    'englishName': 'Luganda',
    'emoji': '🇺🇬',
  },
  'lv': {
    'nativeName': 'Latviešu',
    'englishName': 'Latvian',
    'emoji': '🇱🇻',
  },
  'lv-lv': {
    'nativeName': 'Latviešu',
    'englishName': 'Latvian',
    'emoji': '🇱🇻',
  },
  'ln': {
    'nativeName': 'Ngala',
    'englishName': 'Lingala',
    'emoji': '🇨🇩',
  },
  'mai': {
    'nativeName': 'मैथिली, মৈথিলী',
    'englishName': 'Maithili',
    'emoji': '🏳',
  },
  'mg': {
    'nativeName': 'Malagasy',
    'englishName': 'Malagasy',
    'emoji': '🇲🇬',
  },
  'mk': {
    'nativeName': 'Македонски',
    'englishName': 'Macedonian',
    'emoji': '🇲🇰',
  },
  'mk-mk': {
    'nativeName': 'Македонски (Македонски)',
    'englishName': 'Macedonian (Macedonian)',
    'emoji': '🇲🇰',
  },
  'ml': {
    'nativeName': 'മലയാളം',
    'englishName': 'Malayalam',
    'emoji': '🇮🇳',
  },
  'ml-in': {
    'nativeName': 'മലയാളം',
    'englishName': 'Malayalam',
    'emoji': '🇮🇳',
  },
  'mn-mn': {
    'nativeName': 'Монгол',
    'englishName': 'Mongolian',
    'emoji': '🇲🇳',
  },
  'mr': {
    'nativeName': 'मराठी',
    'englishName': 'Marathi',
    'emoji': '🇮🇳',
  },
  'mr-in': {
    'nativeName': 'मराठी',
    'englishName': 'Marathi',
    'emoji': '🇮🇳',
  },
  'mni-Mtei': {
    'nativeName': 'Manipuri',
    'englishName': 'Meiteilon (Manipuri)',
    'emoji': '🇮🇳',
  },
  'lus': {
    'nativeName': 'Mizo ṭawng',
    'englishName': 'Mizo',
    'emoji': '🏳',
  },
  'ms': {
    'nativeName': 'Bahasa Melayu',
    'englishName': 'Malay',
    'emoji': '🇲🇾',
  },
  'ms-my': {
    'nativeName': 'Bahasa Melayu',
    'englishName': 'Malay',
    'emoji': '🇲🇾',
  },
  'mi': {
    'nativeName': 'Māori',
    'englishName': 'Maori',
    'emoji': '🇳🇿',
  },
  'mt': {
    'nativeName': 'Malti',
    'englishName': 'Maltese',
    'emoji': '🇲🇹',
  },
  'mt-mt': {
    'nativeName': 'Malti',
    'englishName': 'Maltese',
    'emoji': '🇲🇹',
  },
  'my': {
    'nativeName': 'ဗမာစကာ',
    'englishName': 'Burmese',
    'emoji': '🇲🇲',
  },
  'no': {
    'nativeName': 'Norsk',
    'englishName': 'Norwegian',
    'emoji': '🇳🇴',
  },
  'nb': {
    'nativeName': 'Norsk (bokmål)',
    'englishName': 'Norwegian (bokmal)',
    'emoji': '🇳🇴',
  },
  'nb-no': {
    'nativeName': 'Norsk (bokmål)',
    'englishName': 'Norwegian (bokmal)',
    'emoji': '🇳🇴',
  },
  'ne': {
    'nativeName': 'नेपाली',
    'englishName': 'Nepali',
    'emoji': '🇳🇵',
  },
  'ne-np': {
    'nativeName': 'नेपाली',
    'englishName': 'Nepali',
    'emoji': '🇳🇵',
  },
  'nl': {
    'nativeName': 'Nederlands',
    'englishName': 'Dutch',
    'emoji': '🇳🇱',
  },
  'nl-be': {
    'nativeName': 'Nederlands (België)',
    'englishName': 'Dutch (Belgium)',
    'emoji': '🇧🇪',
  },
  'nl-nl': {
    'nativeName': 'Nederlands (Nederland)',
    'englishName': 'Dutch (Netherlands)',
    'emoji': '🇳🇱',
  },
  'nn-no': {
    'nativeName': 'Norsk (nynorsk)',
    'englishName': 'Norwegian (nynorsk)',
    'emoji': '🇳🇴',
  },
  'ny': {
    'nativeName': 'Nyanja',
    'englishName': 'Chewa',
    'emoji': '🏳',
  },
  'oc': {
    'nativeName': 'Occitan',
    'englishName': 'Occitan',
    'emoji': '🏴󠁥󠁳󠁣󠁴󠁿',
  },
  'om': {
    'nativeName': 'Afaan Oromoo',
    'englishName': 'Oromo',
    'emoji': '🏳',
  },
  'or': {
    'nativeName': 'ଓଡ଼ିଆ',
    'englishName': 'Oriya',
    'emoji': '🇮🇳',
  },
  'or-in': {
    'nativeName': 'ଓଡ଼ିଆ',
    'englishName': 'Oriya',
    'emoji': '🇮🇳',
  },
  'pa': {
    'nativeName': 'ਪੰਜਾਬੀ',
    'englishName': 'Punjabi',
    'emoji': '🇮🇳',
  },
  'pa-in': {
    'nativeName': 'ਪੰਜਾਬੀ (ਭਾਰਤ ਨੂੰ)',
    'englishName': 'Punjabi (India)',
    'emoji': '🇮🇳',
  },
  'pl': {
    'nativeName': 'Polski',
    'englishName': 'Polish',
    'emoji': '🇵🇱',
  },
  'pl-pl': {
    'nativeName': 'Polski',
    'englishName': 'Polish',
    'emoji': '🇵🇱',
  },
  'ps': {
    'nativeName': 'پښتو',
    'englishName': 'Pashto',
    'emoji': '🇦🇫',
  },
  'ps-af': {
    'nativeName': 'پښتو',
    'englishName': 'Pashto',
    'emoji': '🇦🇫',
  },
  'pt': {
    'nativeName': 'Português',
    'englishName': 'Portuguese',
    'emoji': '🇧🇷',
  },
  'pt-br': {
    'nativeName': 'Português (Brasil)',
    'englishName': 'Portuguese (Brazil)',
    'emoji': '🇧🇷',
  },
  'pt-pt': {
    'nativeName': 'Português (Portugal)',
    'englishName': 'Portuguese (Portugal)',
    'emoji': '🇵🇹',
  },
  'qu': {
    'nativeName': 'Qhichwa',
    'englishName': 'Quechua',
    'emoji': '🇵🇪',
  },
  'qu-pe': {
    'nativeName': 'Qhichwa',
    'englishName': 'Quechua',
    'emoji': '🇵🇪',
  },
  'rm-ch': {
    'nativeName': 'Rumantsch',
    'englishName': 'Romansh',
    'emoji': '🇸🇪',
  },
  'ro': {
    'nativeName': 'Română',
    'englishName': 'Romanian',
    'emoji': '🇷🇴',
  },
  'ro-ro': {
    'nativeName': 'Română',
    'englishName': 'Romanian',
    'emoji': '🇷🇴',
  },
  'ru': {
    'nativeName': 'Русский',
    'englishName': 'Russian',
    'emoji': '🇷🇺',
  },
  'ru-ru': {
    'nativeName': 'Русский',
    'englishName': 'Russian',
    'emoji': '🇷🇺',
  },
  'sm': {
    'nativeName': 'Gagana faʻa Sāmoa',
    'englishName': 'Samoan',
    'emoji': '🇼🇸',
  },
  'sa': {
    'nativeName': 'संस्कृतम्',
    'englishName': 'Sanskrit',
    'emoji': '🏳',
  },
  'sa-in': {
    'nativeName': 'संस्कृतम्',
    'englishName': 'Sanskrit',
    'emoji': '🏳',
  },
  'se-no': {
    'nativeName': 'Davvisámegiella',
    'englishName': 'Northern Sámi',
    'emoji': '🏳',
  },
  'sh': {
    'nativeName': 'српскохрватски',
    'englishName': 'Serbo-Croatian',
    'emoji': '🇷🇸🇭🇷',
  },
  'si-lk': {
    'nativeName': 'පළාත',
    'englishName': 'Sinhala (Sri Lanka)',
    'emoji': '🇱🇰',
  },
  'sk': {
    'nativeName': 'Slovenčina',
    'englishName': 'Slovak',
    'emoji': '🇸🇰',
  },
  'sk-sk': {
    'nativeName': 'Slovenčina (Slovakia)',
    'englishName': 'Slovak (Slovakia)',
    'emoji': '🇸🇰',
  },
  'sl': {
    'nativeName': 'Slovenščina',
    'englishName': 'Slovenian',
    'emoji': '🇸🇮',
  },
  'sl-si': {
    'nativeName': 'Slovenščina',
    'englishName': 'Slovenian',
    'emoji': '🇸🇮',
  },
  'so': {
    'nativeName': 'Soomaaliga',
    'englishName': 'Somali',
    'emoji': '🇸🇴',
  },
  'sq': {
    'nativeName': 'Shqip',
    'englishName': 'Albanian',
    'emoji': '🇦🇱',
  },
  'sq-al': {
    'nativeName': 'Shqip',
    'englishName': 'Albanian',
    'emoji': '🇦🇱',
  },
  'sr': {
    'nativeName': 'Српски',
    'englishName': 'Serbian',
    'emoji': '🇷🇸',
  },
  'sr-rs': {
    'nativeName': 'Српски (Serbia)',
    'englishName': 'Serbian (Serbia)',
    'emoji': '🇷🇸',
  },
  'su': {
    'nativeName': 'Basa Sunda',
    'englishName': 'Sundanese',
    'emoji': '🇮🇩',
  },
  'sv': {
    'nativeName': 'Svenska',
    'englishName': 'Swedish',
    'emoji': '🇸🇪',
  },
  'sv-se': {
    'nativeName': 'Svenska',
    'englishName': 'Swedish',
    'emoji': '🇸🇪',
  },
  'sw': {
    'nativeName': 'Kiswahili',
    'englishName': 'Swahili',
    'emoji': '🇰🇪',
  },
  'sw-ke': {
    'nativeName': 'Kiswahili',
    'englishName': 'Swahili (Kenya)',
    'emoji': '🇰🇪',
  },
  'ta': {
    'nativeName': 'தமிழ்',
    'englishName': 'Tamil',
    'emoji': '🇮🇳',
  },
  'ta-in': {
    'nativeName': 'தமிழ்',
    'englishName': 'Tamil',
    'emoji': '🇮🇳',
  },
  'te': {
    'nativeName': 'తెలుగు',
    'englishName': 'Telugu',
    'emoji': '🇮🇳',
  },
  'te-in': {
    'nativeName': 'తెలుగు',
    'englishName': 'Telugu',
    'emoji': '🇮🇳',
  },
  'tg': {
    'nativeName': 'забо́ни тоҷикӣ́',
    'englishName': 'Tajik',
    'emoji': '🇹🇯',
  },
  'tg-tj': {
    'nativeName': 'тоҷикӣ',
    'englishName': 'Tajik',
    'emoji': '🇹🇯',
  },
  'th': {
    'nativeName': 'ภาษาไทย',
    'englishName': 'Thai',
    'emoji': '🇹🇭',
  },
  'th-th': {
    'nativeName': 'ภาษาไทย (ประเทศไทย)',
    'englishName': 'Thai (Thailand)',
    'emoji': '🇹🇭',
  },
  'ti': {
    'nativeName': 'ትግርኛ',
    'englishName': 'Tigrinya',
    'emoji': '🏳',
  },
  'ts': {
    'nativeName': 'Xitsonga',
    'englishName': 'Tsonga',
    'emoji': '🏳',
  },
  'tk': {
    'nativeName': 'türkmençe',
    'englishName': 'Turkmen',
    'emoji': '🏳',
  },
  'fil': {
    'nativeName': 'Filipino (Tagalog)',
    'englishName': 'Filipino (Tagalog)',
    'emoji': '🇵🇭',
  },
  'tl': {
    'nativeName': 'Wikang Tagalog',
    'englishName': 'Tagalog',
    'emoji': '🇵🇭',
  },
  'tl-ph': {
    'nativeName': 'Filipino',
    'englishName': 'Filipino',
    'emoji': '🇵🇭',
  },
  'tlh': {
    'nativeName': 'tlhIngan-Hol',
    'englishName': 'Klingon',
    'emoji': '🇹🇷',
  },
  'tr': {
    'nativeName': 'Türkçe',
    'englishName': 'Turkish',
    'emoji': '🇹🇷',
  },
  'tr-tr': {
    'nativeName': 'Türkçe',
    'englishName': 'Turkish',
    'emoji': '🇹🇷',
  },
  'tt': {
    'nativeName': 'татарча',
    'englishName': 'Tatar',
    'emoji': '🇷🇺',
  },
  'uk': {
    'nativeName': 'Українська',
    'englishName': 'Ukrainian',
    'emoji': '🇺🇦',
  },
  'uk-ua': {
    'nativeName': 'Українська',
    'englishName': 'Ukrainian',
    'emoji': '🇺🇦',
  },
  'ug': {
    'nativeName': 'ئۇيغۇر تىلى',
    'englishName': 'Uyghur',
    'emoji': '🇨🇳',
  },
  'uz': {
    'nativeName': 'Oʻzbekcha',
    'englishName': 'Uzbek',
    'emoji': '🏳',
  },
  'ur': {
    'nativeName': 'اردو',
    'englishName': 'Urdu',
    'emoji': '🇵🇰',
  },
  'ur-pk': {
    'nativeName': 'اردو',
    'englishName': 'Urdu',
    'emoji': '🇵🇰',
  },
  'uz-uz': {
    'nativeName': 'O\'zbek',
    'englishName': 'Uzbek',
    'emoji': '🇺🇿',
  },
  'xh': {'nativeName': 'isiXhosa', 'englishName': 'Xhosa', 'emoji': '🇿🇦'},
  'vi': {
    'nativeName': 'Tiếng Việt',
    'englishName': 'Vietnamese',
    'emoji': '🇻🇳'
  },
  'vi-vn': {
    'nativeName': 'Tiếng Việt',
    'englishName': 'Vietnamese',
    'emoji': '🇻🇳'
  },
  'xh-za': {'nativeName': 'isiXhosa', 'englishName': 'Xhosa', 'emoji': '🇿🇦'},
  'yo': {'nativeName': 'Èdè Yorùbá', 'englishName': 'Yoruba', 'emoji': '🏳'},
  'zu': {'nativeName': 'isiZulu', 'englishName': 'Zulu', 'emoji': '🇿🇦'},
  'yi': {'nativeName': 'ייִדיש', 'englishName': 'Yiddish', 'emoji': '🕎'},
  'yi-de': {
    'nativeName': 'ייִדיש (German)',
    'englishName': 'Yiddish (German)',
    'emoji': '🇩🇪'
  },
  'zh': {
    'nativeName': '中文',
    'englishName': 'Chinese Simplified',
    'emoji': '🇨🇳'
  },
  'zh-hans': {
    'nativeName': '中文简体',
    'englishName': 'Chinese Simplified',
    'emoji': '🇨🇳'
  },
  'zh-hant': {
    'nativeName': '中文繁體',
    'englishName': 'Chinese Traditional',
    'emoji': '🇨🇳'
  },
  'zh-cn': {
    'nativeName': '中文（中国）',
    'englishName': 'Chinese Simplified (China)',
    'emoji': '🇨🇳'
  },
  'zh-hk': {
    'nativeName': '中文（香港）',
    'englishName': 'Chinese Traditional (Hong Kong)',
    'emoji': '🇭🇰'
  },
  'zh-sg': {
    'nativeName': '中文（新加坡）',
    'englishName': 'Chinese Simplified (Singapore)',
    'emoji': '🇸🇬'
  },
  'zh-tw': {
    'nativeName': '中文（台灣）',
    'englishName': 'Chinese Traditional (Taiwan)',
    'emoji': '🇹🇼'
  },
  'zu-za': {
    'nativeName': 'isiZulu',
    'englishName': 'Zulu',
    'emoji': '🇿🇦',
  }
};
