//import 'package:flutter/services.dart';
import 'package:programadoro/notifiers/BaseNotifier.dart';
import 'package:just_audio/just_audio.dart';

class SoundNotifier implements BaseNotifier {
  AudioPlayer player;

  SoundNotifier() : player = AudioPlayer();

  @override
  Future<void> notify() async {
   // await SystemSound.play(SystemSoundType.click);

    await player.setAsset('assets/audio/alarm.mp3');
    player.play();
  }

  void dispose() {
    player.dispose();
  }
}
