import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _localePreferenceKey = 'app_locale';

// Provider for SharedPreferences instance
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await SharedPreferences.getInstance();
});

// StateNotifier for managing the locale
class LocaleNotifier extends StateNotifier<Locale?> {
  final SharedPreferences _prefs;

  LocaleNotifier(this._prefs) : super(null) {
    _loadLocale();
  }

  // Load saved locale or determine default
  void _loadLocale() {
    final savedLocaleCode = _prefs.getString(_localePreferenceKey);
    if (savedLocaleCode != null && savedLocaleCode.isNotEmpty) {
      state = Locale(savedLocaleCode);
      print("[LocaleNotifier] Loaded saved locale: $savedLocaleCode");
    } else {
      // If no locale saved, don't set state yet.
      // MaterialApp will use system locale by default if locale is null.
      print("[LocaleNotifier] No saved locale found. Will use system default.");
      state = null; // Explicitly null means use system default
    }
  }

  // Change and save locale
  Future<void> setLocale(Locale newLocale) async {
    if (state?.languageCode != newLocale.languageCode) {
      state = newLocale;
      await _prefs.setString(_localePreferenceKey, newLocale.languageCode);
      print(
        "[LocaleNotifier] Set and saved new locale: ${newLocale.languageCode}",
      );
    }
  }

}
