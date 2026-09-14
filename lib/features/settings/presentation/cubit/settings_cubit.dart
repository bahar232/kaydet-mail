import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsCubit extends Cubit<AppSettings> {
  final SettingsRepository _repository;

  SettingsCubit(this._repository) : super(const AppSettings());

  Future<void> load() async {
    emit(await _repository.fetchSettings());
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final updated = state.copyWith(notificationsEnabled: enabled);
    emit(updated);
    await _repository.saveSettings(updated);
  }

  Future<void> setSyncFrequency(String frequency) async {
    final updated = state.copyWith(syncFrequency: frequency);
    emit(updated);
    await _repository.saveSettings(updated);
  }
}
