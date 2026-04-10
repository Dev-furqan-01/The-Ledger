class SplashContent {
  final String title;
  final String subtitle;
  final String statusText;

  const SplashContent({
    required this.title,
    required this.subtitle,
    required this.statusText,
  });

  factory SplashContent.initial() {
    return const SplashContent(
      title: 'The Ledger',
      subtitle: 'PRIVATE FINANCIAL INTELLIGENCE',
      statusText: 'SECURE ACCESS GRANTED',
    );
  }
}
