import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class MockSettingsRepository implements SettingsRepository {
  AppSettings _settings = const AppSettings();

  @override
  Future<AppSettings> fetchSettings() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _settings;
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _settings = settings;
  }
}
