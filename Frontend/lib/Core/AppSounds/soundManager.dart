import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  SoundManager._();
  static final AudioPlayer player = AudioPlayer();
  static Future<void> playNotification() async {
    await player.play(AssetSource('sounds/notification.mp3'));
  }

  static Future<void> playNavSound() async {
    await player.play(AssetSource('sounds/botto_nav.mp3'));
  }

  static Future<void> playDeleteSound() async {
    await player.play(AssetSource('sounds/woosh_delete.mp3'));
  }

  static Future<void> playPopUpSound() async {
    await player.play(AssetSource('sounds/new_pop.mp3'));
  }
}
// class SoundManager {
//   SoundManager._();

//   static Future<void> _play(String asset) async {
//     final player = AudioPlayer();
//     await player.play(AssetSource(asset));

//     // Dispose after playback ends
//     player.onPlayerComplete.listen((_) {
//       player.dispose();
//     });
//   }

//   static void playNotification() {
//     _play('sounds/notification.mp3');
//   }

//   static void playNavSound() {
//     _play('sounds/bottom_nav.mp3');
//   }

//   static void playDeleteSound() {
//     _play('sounds/woosh_delete.mp3');
//   }

//   static void playPopUpSound() {
//     _play('sounds/new_pop.mp3');
//   }
// }
