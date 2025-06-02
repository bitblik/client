import 'dart:async'; // Import for StreamSubscription
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../i18n/gen/strings.g.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FaqScreen extends ConsumerStatefulWidget {
  const FaqScreen({super.key});

  static const routeName = '/faq';
  @override
  ConsumerState<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends ConsumerState<FaqScreen> {
  String? _htmlContent;
  bool _isLoading = true;
  String _error = '';
  StreamSubscription<AppLocale>? _localeSubscription;
  AppLocale? _currentLocale;


  @override
  void initState() {
    super.initState();
    _currentLocale = LocaleSettings.currentLocale;
    _loadFaqContent(); // Initial load

    _localeSubscription = LocaleSettings.getLocaleStream().listen((locale) {
      // Check if the locale actually changed to avoid redundant loads if the stream emits the same locale
      if (_currentLocale != locale) {
        print("FAQ Screen: Locale changed to $locale, reloading content.");
        _currentLocale = locale;
        _loadFaqContent();
      }
    });
  }

  // Remove didChangeDependencies as locale changes are now handled by the stream
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final currentLocale = LocaleSettings.currentLocale;
  //   if (_htmlContent == null || (_previousLocale != null && _previousLocale != currentLocale)) {
  //     _loadFaqContent();
  //   }
  //   _previousLocale = currentLocale;
  // }

  @override
  void dispose() {
    _localeSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadFaqContent() async {
    // Use _currentLocale which is updated by the stream listener, or fallback to LocaleSettings.currentLocale
    // This ensures that if _loadFaqContent is called before the stream listener has a chance to update _currentLocale
    // (e.g. during initState), it still uses the correct, most up-to-date locale.
    final localeToLoad = _currentLocale ?? LocaleSettings.currentLocale;
    print("FAQ Screen: Loading content for locale: $localeToLoad");

    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      // final locale = LocaleSettings.currentLocale; // Use localeToLoad instead
      String langCode = localeToLoad.languageCode.toLowerCase();
      String filePath = 'assets/faq/faq_$langCode.md';
      String markdownData;

      try {
        markdownData = await rootBundle.loadString(filePath);
      } catch (e) {
        print('Could not load FAQ for language: $langCode. Falling back to English. Error: $e');
        langCode = 'en';
        filePath = 'assets/faq/faq_$langCode.md';
        try {
          markdownData = await rootBundle.loadString(filePath);
        } catch (fallbackError) {
          print('Could not load English fallback FAQ. Error: $fallbackError');
          throw Exception('Failed to load FAQ content for $langCode and fallback en.');
        }
      }
      
      // Convert Markdown to HTML
      final html = md.markdownToHtml(markdownData, inlineSyntaxes: [md.InlineHtmlSyntax()]);
      
      setState(() {
        _htmlContent = html; // Store HTML content
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load FAQ content: ${e.toString()}';
      });
      print('Error loading FAQ: $_error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final t = Translations.of(context); // Access translations if needed for other parts

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _error,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_htmlContent == null) {
      return const Center(child: Text('No FAQ content available.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0), // Apply padding to SingleChildScrollView
      child: Html(
        data: _htmlContent!,
        onLinkTap: (url, attributes, element) {
          if (url != null) {
            launchUrlString(url);
          }
        },
        // You can customize styles using the style parameter for flutter_html
        // style: {
        //   "h1": Style(textAlign: TextAlign.center),
        //   // Add more styles as needed
        // },
      ),
    );
  }
}
