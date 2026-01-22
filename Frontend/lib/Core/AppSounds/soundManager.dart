import 'package:audioplayers/audioplayers.dart';

class Soundmanager {
  Soundmanager._();

  static final AudioPlayer player = AudioPlayer();

  static Future<void> playNotification() async {
    await player.play(AssetSource('sounds/notification.mp3'));
  }

  static Future<void> playNavSound() async {
    await player.play(AssetSource('sounds/botto_nav.mp3'));
  }
}
