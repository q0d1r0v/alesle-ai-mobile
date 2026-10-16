/// Pages on the website the app links to (SOW 08 §3, AC-WEB-4).
enum WebPage {
  privacy('privacy'),
  terms('terms'),
  refund('refund'),
  deleteAccount('delete-account'),
  support('support');

  const WebPage(this.slug);

  final String slug;
}

const Set<String> _siteLanguages = <String>{'en', 'uz', 'ru'};

/// `https://alesle.ai/<language>/<page>`; English for other languages.
Uri webPageUrl(WebPage page, String language) => Uri.https(
  'alesle.ai',
  '/${_siteLanguages.contains(language) ? language : 'en'}/${page.slug}',
);
