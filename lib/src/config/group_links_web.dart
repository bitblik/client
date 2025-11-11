import 'package:web/web.dart';
import 'dart:js_interop';
import 'package:ndk/shared/logger/logger.dart';
import 'group_links_constants.dart';

/// Extension type for accessing window.appConfig JavaScript object
@JS()
extension type AppConfig(JSObject _) implements JSObject {
  external String? get telegramGroupLink;
  external String? get elementGroupLink;
  external String? get simplexGroupLink;
  external String? get signalGroupLink;
}

/// Extension type for accessing window JavaScript object
@JS()
extension type JSWindow(JSObject _) implements JSObject {
  external AppConfig? get appConfig;
}

/// Web-specific implementation for group links loaded from JavaScript config at runtime
/// The config is loaded from /config.js which can be mounted/overwritten in Docker
class GroupLinks {
  static String? _telegram;
  static String? _element;
  static String? _simplex;
  static String? _signal;
  static bool _initialized = false;

  /// Initialize group links from window.appConfig object
  /// Falls back to default constants if not configured
  static void _initialize() {
    if (_initialized) return;

    try {
      // Access window.appConfig from JavaScript using dart:js_interop
      final windowObj = window as JSObject;
      final windowTyped = JSWindow(windowObj);
      final appConfig = windowTyped.appConfig;

      if (appConfig != null) {
        final telegramLink = appConfig.telegramGroupLink;
        final elementLink = appConfig.elementGroupLink;
        final simplexLink = appConfig.simplexGroupLink;
        final signalLink = appConfig.signalGroupLink;

        // Use configured value if provided, otherwise use default constant
        _telegram =
            telegramLink?.isNotEmpty == true
                ? telegramLink
                : GroupLinksConstants.defaultTelegram;
        _element =
            elementLink?.isNotEmpty == true
                ? elementLink
                : GroupLinksConstants.defaultElement;
        _simplex =
            simplexLink?.isNotEmpty == true
                ? simplexLink
                : GroupLinksConstants.defaultSimplex;
        _signal =
            signalLink?.isNotEmpty == true
                ? signalLink
                : GroupLinksConstants.defaultSignal;
      } else {
        // No config available, use default constants
        _telegram = GroupLinksConstants.defaultTelegram;
        _element = GroupLinksConstants.defaultElement;
        _simplex = GroupLinksConstants.defaultSimplex;
        _signal = GroupLinksConstants.defaultSignal;
      }
    } catch (e) {
      Logger.log.w('⚠️ Error loading group links config: $e');
      // Fall back to default constants on error
      _telegram = GroupLinksConstants.defaultTelegram;
      _element = GroupLinksConstants.defaultElement;
      _simplex = GroupLinksConstants.defaultSimplex;
      _signal = GroupLinksConstants.defaultSignal;
    }

    _initialized = true;
  }

  /// Telegram group link
  static String get telegram {
    _initialize();
    return _telegram ?? GroupLinksConstants.defaultTelegram;
  }

  /// Element/Matrix group link
  static String get element {
    _initialize();
    return _element ?? GroupLinksConstants.defaultElement;
  }

  /// SimpleX group link
  static String get simplex {
    _initialize();
    return _simplex ?? GroupLinksConstants.defaultSimplex;
  }

  /// Signal group link
  static String get signal {
    _initialize();
    return _signal ?? GroupLinksConstants.defaultSignal;
  }

  /// Check if any group links are configured
  static bool get hasAnyLinks {
    _initialize();
    return telegram.isNotEmpty ||
        element.isNotEmpty ||
        simplex.isNotEmpty ||
        signal.isNotEmpty;
  }
}
