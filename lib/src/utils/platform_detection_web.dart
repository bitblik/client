import 'dart:html' as html;

/// Web-specific implementation for platform detection using user agent

bool isAndroidUserAgent() {
  final userAgent = html.window.navigator.userAgent.toLowerCase();
  return userAgent.contains('android');
}

bool isIOSUserAgent() {
  final userAgent = html.window.navigator.userAgent.toLowerCase();
  return userAgent.contains('iphone') ||
      userAgent.contains('ipad') ||
      userAgent.contains('ipod');
}