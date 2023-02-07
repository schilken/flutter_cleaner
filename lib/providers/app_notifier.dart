// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'disk_usage_notifier.dart';
import 'disk_usage_repository.dart';
import 'providers.dart';

class AppState {
  String message;
  String appVersion;
  String currentDirectory;

  AppState({
    required this.message,
    required this.appVersion,
    required this.currentDirectory,
  });

  AppState copyWith({
    String? message,
    String? appVersion,
    String? currentDirectory,
  }) {
    return AppState(
      message: message ?? this.message,
      appVersion: appVersion ?? this.appVersion,
      currentDirectory: currentDirectory ?? this.currentDirectory,
    );
  }

  @override
  bool operator ==(covariant AppState other) {
    if (identical(this, other)) return true;

    return other.message == message;
  }

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'AppState(message: $message)';
}

class AppNotifier extends Notifier<AppState> {
  late PreferencesRepository _preferencesRepository;
  late DiskUsageRepository _diskUsageRepository;

  @override
  AppState build() {
    _preferencesRepository = ref.read(preferencesRepositoryProvider);
    _diskUsageRepository = ref.read(diskUsageRepositoryProvider);
    return AppState(
      message: 'initialized',
      appVersion: _preferencesRepository.appVersion,
      currentDirectory: _preferencesRepository.currentDirectory,
    );
  }

  void setCurrentDirectory({required String directoryPath}) {
    _preferencesRepository.setCurrentDirectory(directoryPath);
    state = state.copyWith(currentDirectory: directoryPath);
    debugPrint('setDefaultDirectory: $directoryPath');
  }

}

final appNotifier = NotifierProvider<AppNotifier, AppState>(AppNotifier.new);
