/// Rules for what the user says hands-free (SOW 04 §4.3). Pure Dart.
library;

const Set<String> _stopWords = <String>{
  // uz
  "to'xta", "to'xtat", 'toxta', 'toxtat', "to'xtating", 'bas', 'yetadi',
  // ru
  'стоп', 'остановись', 'останови', 'хватит', 'отмена', 'отмени',
  // en
  'stop', 'cancel',
};

/// Words that may come with a stop and change nothing.
const Set<String> _filler = <String>{
  'alesle',
  'iltimos',
  'hozir',
  'darhol',
  'please',
  'now',
  'пожалуйста',
  'сейчас',
  'ok',
  'ок',
  'okay',
};

/// True when the whole utterance only asks to stop ("To'xta!", "Alesle,
/// stop", "хватит"). "Taymerni to'xtat" is a command for the agent, not
/// this: something besides stop words and filler was said.
bool isStopCommand(String text) {
  final List<String> words = text
      .toLowerCase()
      .replaceAll(RegExp('[‘’ʻʼ`]'), "'")
      .replaceAll(RegExp(r"[^\p{L}\p{N}' ]", unicode: true), ' ')
      .split(RegExp(r'\s+'))
      .where((String word) => word.isNotEmpty && !_filler.contains(word))
      .toList();
  if (words.isEmpty || words.length > 2) return false;
  if (words.length == 2) {
    // The only two-word stop: "bekor qil" (cancel).
    return words[0] == 'bekor' && words[1] == 'qil';
  }
  return _stopWords.contains(words.single);
}

/// The language a spoken command gets its answer in: what was heard when the
/// speech service could tell, else the app's.
String replyLocale(String heard, String appLocale) =>
    const <String>{'uz', 'ru', 'en'}.contains(heard) ? heard : appLocale;
