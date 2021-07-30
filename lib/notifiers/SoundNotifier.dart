import 'package:flutter/services.dart';
import 'package:programadoro/notifiers/BaseNotifier.dart';

class SoundNotifier implements BaseNotifier {
  @override
  Future<void> notify() async {
     await SystemSound.play(SystemSoundType.click);
  }
}