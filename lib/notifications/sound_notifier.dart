import 'package:cododoro/common/data_layer/volume_controller.dart';

import 'package:cododoro/notifications/base_notifier.dart';
import 'package:just_audio/just_audio.dart';

class SoundNotifier implements BaseNotifier {
  AudioPlayer player;

  SoundNotifier() : player = AudioPlayer();

  @override
  Future<void> notify(message,
      {String? soundPath, Duration delay = Duration.zero}) async {
    if (volumeController.isSoundOn) {
      await Future.delayed(delay);
      await player.setAsset(soundPath ?? 'assets/audio/alarm.mp3');
      player.setVolume(0.04);
      player.play();
    }
  }

  void dispose() {
    player.dispose();
  }
}
