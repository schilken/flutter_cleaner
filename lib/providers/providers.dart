import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'app_notifier.dart';
export 'disk_usage_notifier.dart';
export 'disk_usage_repository.dart';
export 'preferences_repository.dart';
export 'settings_notifier.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
  name: 'SharedPreferencesProvider',
);
