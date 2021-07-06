import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod/riverpod.dart';

class AppSettings {
  final bool vibrateSetting;
  AppSettings({required this.vibrateSetting});
}

abstract class SettingsState {
  const SettingsState();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final AppSettings appSettings;
  const SettingsLoaded(this.appSettings);
}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is SettingsError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

class SettingsNotifier<SettingsState> extends StateNotifier {
  SettingsNotifier([SettingsState? state]) : super(SettingsLoading()) {
    initialise();
  }
  final storage = FlutterSecureStorage();

  void initialise() async {
    try {
      state = SettingsLoaded(AppSettings(
          vibrateSetting:
              await storage.read(key: 'vibration_setting') == "true"));
    } catch (e) {
      state = SettingsError("Unable to load app settings");
    }
  }

  void update(AppSettings appSettings) async {
    await storage.write(
        key: 'vibration_setting',
        value: appSettings.vibrateSetting ? 'true' : 'false');
    initialise();
  }
}
