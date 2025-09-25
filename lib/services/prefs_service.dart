import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static Future<bool> getOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }

  static Future<void> setOnboardingCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', value);
  }

  static Future<void> setMarketingConsent(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('marketing_consent', value);
  }
}
