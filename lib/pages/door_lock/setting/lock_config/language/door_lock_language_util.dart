import 'package:fcloudsdk/door_lock/door_lock_enum.dart';
import 'package:fcloudsdk/utils/bit_util.dart';

const _languageNames = <DoorLockLanguage, String>{
  DoorLockLanguage.zh_CN: '简体中文',
  DoorLockLanguage.en: 'English',
  DoorLockLanguage.zh_TW: '繁體中文',
  DoorLockLanguage.it: 'Italiano',
  DoorLockLanguage.es: 'Español',
  DoorLockLanguage.ja: '日本語',
  DoorLockLanguage.ru: 'Русский',
  DoorLockLanguage.fr: 'Français',
  DoorLockLanguage.de: 'Deutsch',
  DoorLockLanguage.pt_PT: 'Português(Portugal)',
  DoorLockLanguage.tr: 'Türkçe',
  DoorLockLanguage.pl: 'Polski',
  DoorLockLanguage.ro: 'Română',
  DoorLockLanguage.hu: 'Magyar',
  DoorLockLanguage.fi: 'Suomi',
  DoorLockLanguage.et: 'Eesti',
  DoorLockLanguage.ko: '한국어',
  DoorLockLanguage.fa: 'فارسی',
  DoorLockLanguage.da: 'Dansk',
  DoorLockLanguage.th: 'ไทย',
  DoorLockLanguage.el: 'Ελληνικά',
  DoorLockLanguage.vi: 'Tiếng Việt',
  DoorLockLanguage.uk: 'Українська',
  DoorLockLanguage.pt_BR: 'Português (Brasil)',
  DoorLockLanguage.he: 'עברית',
  DoorLockLanguage.id: 'Bahasa Indonesia',
  DoorLockLanguage.ar: 'العربية',
  DoorLockLanguage.sv: 'Svenska',
  DoorLockLanguage.cs: 'Čeština',
  DoorLockLanguage.bg: 'Български',
  DoorLockLanguage.sk: 'Slovenčina',
  DoorLockLanguage.nl: 'Nederlands',
  DoorLockLanguage.sr: 'Српски',
  DoorLockLanguage.hr: 'Hrvatski',
  DoorLockLanguage.az: 'Azərbaycan',
  DoorLockLanguage.kk: 'Қазақша',
};

String doorLockLanguageName(DoorLockLanguage? language) {
  return _languageNames[language] ?? '未知';
}

List<DoorLockLanguage> parseDoorLockLanguages(List<int>? masks) {
  final languages = <DoorLockLanguage>[];
  for (var byteIndex = 0; byteIndex < (masks?.length ?? 0); byteIndex++) {
    for (var bit = 0; bit < 8; bit++) {
      if (!getBit(masks![byteIndex], bit)) continue;
      final language = DoorLockLanguage.from(byteIndex * 8 + bit);
      if (language == DoorLockLanguage.unknown ||
          language == DoorLockLanguage.reserved ||
          languages.contains(language)) {
        continue;
      }
      languages.add(language);
    }
  }
  if (languages.isEmpty) {
    languages.addAll(const [DoorLockLanguage.zh_CN, DoorLockLanguage.en]);
  }
  return languages;
}
