// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;

import 'providers.dart';

@immutable
class AppState {
  final String appVersion;
  final String currentDirectory;
  final bool? selectAllBox;

  const AppState({
    required this.appVersion,
    required this.currentDirectory,
    this.selectAllBox,
  });

  AppState copyWith({
    String? appVersion,
    String? currentDirectory,
    bool? checkAllBox,
  }) {
    return AppState(
      appVersion: appVersion ?? this.appVersion,
      currentDirectory: currentDirectory ?? this.currentDirectory,
      selectAllBox: checkAllBox,
    );
  }

  @override
  bool operator ==(covariant AppState other) {
    if (identical(this, other)) return true;
  
    return other.appVersion == appVersion &&
        other.currentDirectory == currentDirectory &&
        other.selectAllBox == selectAllBox;
  }

  @override
  int get hashCode {
    return appVersion.hashCode ^
        currentDirectory.hashCode ^
        selectAllBox.hashCode;
  }

  @override
  String toString() {
    return 'AppState(appVersion: $appVersion, currentDirectory: $currentDirectory, selectAllBox: $selectAllBox)';
  }
}

class AppNotifier extends Notifier<AppState> {
  late PreferencesRepository _preferencesRepository;

  @override
  AppState build() {
    _preferencesRepository = ref.read(preferencesRepositoryProvider);
    return AppState(
      appVersion: _preferencesRepository.appVersion,
      currentDirectory: _preferencesRepository.currentDirectory,
      selectAllBox: false,
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

  void updateChecked(bool? value) {
    debugPrint('updateChecked: $value');
    state = state.copyWith(checkAllBox: value ?? false);
    ref.read(diskUsageNotifierProvider.notifier).selectAll(value ?? false);
  }
}

final appNotifierProvider =
    NotifierProvider<AppNotifier, AppState>(AppNotifier.new);
