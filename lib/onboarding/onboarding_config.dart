import 'package:shared_preferences/shared_preferences.dart';

class OnboardingConfig {
  final onboardingStepKey = "CURRENT_ONBOARDING_STEP";

  int _stepShown = 0;

  get stepShown => _stepShown;

  Future<void> setStepShown(newStep) async {
    _stepShown = newStep;

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(onboardingStepKey, newStep);
  }

  Future<OnboardingConfig> init() async {
    final prefs = await SharedPreferences.getInstance();

    _stepShown = prefs.getInt(onboardingStepKey) ?? 0;

    return this;
  }
}
