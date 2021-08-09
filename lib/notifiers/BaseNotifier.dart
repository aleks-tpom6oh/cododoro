abstract class BaseNotifier {
  Future<void> notify(String message);

  void dispose();
}
