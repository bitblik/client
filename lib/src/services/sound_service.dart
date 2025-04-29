import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

class SoundService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playSound(String mp3) async {
    try {
      // Use AssetSource for assets declared in pubspec.yaml
      await _audioPlayer.play(AssetSource('sounds/${mp3}.mp3'));
      if (kDebugMode) {
        print('[SoundService] Played success sound.');
      }
    } catch (e) {
      // Log error only in debug mode to avoid spamming release builds
      if (kDebugMode) {
        print('[SoundService] Error playing sound: $e');
        print(
          '[SoundService] Ensure "assets/sounds/success.mp3" exists and is declared in pubspec.yaml',
        );
      }
      // Optionally, handle the error more gracefully (e.g., show a silent notification)
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
