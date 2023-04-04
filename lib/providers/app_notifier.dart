// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;

import 'providers.dart';

@immutable
class AppState {
  final String message;
  final String appVersion;
  final String currentDirectory;

  const AppState({
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

  @override
  AppState build() {
    _preferencesRepository = ref.read(preferencesRepositoryProvider);
    return AppState(
      message: 'initialized',
      appVersion: _preferencesRepository.appVersion,
      currentDirectory: _preferencesRepository.currentDirectory,
    );
  }

  void setCurrentDirectory({required String directoryPath}) {
    final reducedPath = _startWithUsersFolder(directoryPath);
    _preferencesRepository.setCurrentDirectory(reducedPath);
    state = state.copyWith(currentDirectory: reducedPath);
    debugPrint('setDefaultDirectory: $reducedPath');
  }

  String _startWithUsersFolder(String fullPathName) {
    final parts = p.split(fullPathName);
    if (parts.length > 3 && parts[3] == 'Users') {
      return '/${p.joinAll(parts.sublist(3))}';
    }
    return fullPathName;
  }
}

final appNotifierProvider =
    NotifierProvider<AppNotifier, AppState>(AppNotifier.new);
