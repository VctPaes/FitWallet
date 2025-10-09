import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _kOnboardingDone = 'onboarding_completed';
  static const _kMarketingConsent = 'marketing_consent';
  static const _kConsentTime = 'consent_accepted_at';
  static const _kWeeklyGoal = 'weekly_goal';
  static const _kExpensesKey = 'expenses_json';

  final SharedPreferences _prefs;
  PrefsService._(this._prefs);

  static Future<PrefsService> init() async {
    final p = await SharedPreferences.getInstance();
    return PrefsService._(p);
  }

  bool get onboardingCompleted => _prefs.getBool(_kOnboardingDone) ?? false;
  Future<void> setOnboardingCompleted(bool value) async =>
      _prefs.setBool(_kOnboardingDone, value);

  bool get marketingConsent => _prefs.getBool(_kMarketingConsent) ?? false;
  Future<void> setMarketingConsent(bool value) async {
    await _prefs.setBool(_kMarketingConsent, value);
    if (value) {
      await _prefs.setString(_kConsentTime, DateTime.now().toIso8601String());
    } else {
      await _prefs.remove(_kConsentTime);
    }
  }

  String? get consentAcceptedAt => _prefs.getString(_kConsentTime);

  int get weeklyGoal => _prefs.getInt(_kWeeklyGoal) ?? 0;
  Future<void> setWeeklyGoal(int value) async =>
      _prefs.setInt(_kWeeklyGoal, value);

  String? get expensesJson => _prefs.getString(_kExpensesKey);
  Future<void> setExpensesJson(String json) async =>
      _prefs.setString(_kExpensesKey, json);

  Future<void> clearAll() => _prefs.clear();
}
