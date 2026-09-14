import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final bool notificationsEnabled;
  final String syncFrequency; // push, 15min, 30min, 1hour, manual

  const AppSettings({this.notificationsEnabled = true, this.syncFrequency = 'push'});

  AppSettings copyWith({bool? notificationsEnabled, String? syncFrequency}) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      syncFrequency: syncFrequency ?? this.syncFrequency,
    );
  }

  @override
  List<Object?> get props => [notificationsEnabled, syncFrequency];
}
