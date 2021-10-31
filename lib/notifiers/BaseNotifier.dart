abstract class BaseNotifier {
  Future<void> notify(String message, {String? soundPath});

  void dispose();
}
