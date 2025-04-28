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

  // Clear saved locale preference
  Future<void> clearLocalePreference() async {
    state = null; // Revert to system default
    await _prefs.remove(_localePreferenceKey);
    print("[LocaleNotifier] Cleared saved locale preference.");
  }
}

// The provider for the LocaleNotifier
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider).value;
  // Handle the case where SharedPreferences is not yet available
  if (sharedPreferences == null) {
    // Return a temporary notifier with dummy prefs or handle loading state
    // For simplicity, let's throw or return a default state temporarily
    // Ideally, the UI should handle the loading state of sharedPreferencesProvider
    print("[localeProvider] SharedPreferences not ready yet.");
    // Returning a notifier that does nothing until prefs are ready
    // This might cause issues if accessed too early. Consider using AsyncValue.
    return LocaleNotifier(
      _DummyPreferences(),
    ); // Use a dummy for initialization phase
  }
  return LocaleNotifier(sharedPreferences);
});

// Dummy SharedPreferences implementation for initial provider state before async load completes
class _DummyPreferences implements SharedPreferences {
  @override
  Future<bool> clear() async => true;

  @override
  Future<bool> commit() async => true;

  @override
  bool containsKey(String key) => false;

  @override
  Object? get(String key) => null;

  @override
  bool? getBool(String key) => null;

  @override
  double? getDouble(String key) => null;

  @override
  int? getInt(String key) => null;

  @override
  Set<String> getKeys() => {};

  @override
  String? getString(String key) => null;

  @override
  List<String>? getStringList(String key) => null;

  @override
  Future<void> reload() async {}

  @override
  Future<bool> remove(String key) async => true;

  @override
  Future<bool> setBool(String key, bool value) async => true;

  @override
  Future<bool> setDouble(String key, double value) async => true;

  @override
  Future<bool> setInt(String key, int value) async => true;

  @override
  Future<bool> setString(String key, String value) async => true;

  @override
  Future<bool> setStringList(String key, List<String> value) async => true;
}
