abstract class BaseNotifier {
  Future<void> notify(String message, {String? soundPath, Duration delay = Duration.zero});

  void dispose();
}