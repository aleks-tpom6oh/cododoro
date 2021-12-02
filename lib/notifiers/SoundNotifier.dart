import 'package:cododoro/models/VolumeController.dart';
import 'package:cododoro/notifiers/BaseNotifier.dart';
import 'package:just_audio/just_audio.dart';

class SoundNotifier implements BaseNotifier {
  AudioPlayer player;

  SoundNotifier() : player = AudioPlayer();

  @override
  Future<void> notify(message, {String? soundPath}) async {
    if (volumeController.isSoundOn) {
      await player.setAsset(soundPath ?? 'assets/audio/t-bell.mp3');
      player.play();
    }
  }

  void dispose() {
    player.dispose();
  }
}
