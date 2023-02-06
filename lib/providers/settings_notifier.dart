// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'providers.dart';

class SettingsState {
  String currentDirectory;
  String appVersion;

  SettingsState({
    required this.currentDirectory,
    required this.appVersion,
  });

  SettingsState copyWith({
    String? currentDirectory,
    String? appVersion,
  }) {
    return SettingsState(
      currentDirectory: currentDirectory ?? this.currentDirectory,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  late PreferencesRepository _preferencesRepository;

  @override
  SettingsState build() {
    _preferencesRepository = ref.read(preferencesRepositoryProvider);
    return SettingsState(
      currentDirectory: _preferencesRepository.currentDirectory,
      appVersion: _preferencesRepository.appVersion,
    );
  }
}

final settingsNotifier =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
