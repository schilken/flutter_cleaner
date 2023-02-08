import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;

import '../data/disk_usage_record.dart';
import 'disk_usage_repository.dart';

typedef AsyncResult = AsyncValue<List<DiskUsageRecord>?>;

class DiskUsageNotifier extends AsyncNotifier<List<DiskUsageRecord>?> {
  DiskUsageNotifier();

  late DiskUsageRepository _diskUsageRepository;
  final _records = <DiskUsageRecord>[];

  @override
  FutureOr<List<DiskUsageRecord>?> build() async {
    _diskUsageRepository = ref.read(diskUsageRepositoryProvider);
    return null;
  }

  Future<void> scan(String directory) async {
    _records.clear();
    state = const AsyncValue.loading();
    state = await AsyncResult.guard(
      () => _diskUsageRepository.scanDiskUsage(directory),
    );
    _records.addAll(state.value ?? []);
  }

  bool get isLoading => state.isLoading;

  void selectRecord(int index, bool? value) {
    _records[index] = _records[index].copyWith(isSelected: value);
    state = AsyncValue.data(_records);
  }

  Future<String> deleteSelectedDirectories() async {
    debugPrint('deleteSelectedDirectories');
    final directoriesToDelete =
        _records.where((r) => r.isSelected).map((r) => r.directoryPath);
    final baseDirectory = _diskUsageRepository.currentDirectory;
    if (baseDirectory == null) {
      return 'No base directory configured.';
    }
    final allFiles = directoriesToDelete.length;
    var deletedFiles = 0;
    for (final subDirectory in directoriesToDelete) {
      final fullPath = p.join(baseDirectory, subDirectory);
      final exitCode = await moveToTrash(fullPath);
      if (exitCode == 0) {
        deletedFiles++;
      }
    }
    scan(baseDirectory);
    return '$deletedFiles of $allFiles deleted';
  }

// osascript -e "tell application \"Finder\" to delete POSIX file \"${PWD}/${InputFile}\""
  Future<int> moveToTrash(String pathName) async {
    var process = await Process.run('osascript',
        ['-e', 'tell application "Finder" to delete POSIX file "$pathName"']);
    if (process.exitCode != 0) {
      debugPrint('moveToTrash failed:');
      debugPrint(process.stderr);
    }
    return process.exitCode;
  }

}

final diskUsageNotifier =
    AsyncNotifierProvider<DiskUsageNotifier, List<DiskUsageRecord>?>(() {
  return DiskUsageNotifier();
});

final selectedRecordCountProvider = Provider<int>((ref) {
  final diskUsageAsyncValue = ref.watch(diskUsageNotifier);
  return diskUsageAsyncValue.maybeMap<int>(
      data: (data) {
        final records = data.value ?? [];
        return records.where((r) => r.isSelected).length;
      },
      orElse: () => 0);
});

final totalSizeProvider = Provider<int>((ref) {
  final diskUsageAsyncValue = ref.watch(diskUsageNotifier);
  return diskUsageAsyncValue.maybeMap<int>(
      data: (data) {
        final records = data.value ?? [];
        return records.fold(0, (sum, r) => sum + r.size);
      },
      orElse: () => 0);
});

final selectedSizeProvider = Provider<int>((ref) {
  final diskUsageAsyncValue = ref.watch(diskUsageNotifier);
  return diskUsageAsyncValue.maybeMap<int>(
      data: (data) {
        final records = data.value ?? [];
        return records
            .where((r) => r.isSelected)
            .fold(0, (sum, r) => sum + r.size);
      },
      orElse: () => 0);
});
