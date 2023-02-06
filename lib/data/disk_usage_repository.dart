// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;

import 'disk_usage_record.dart';
import 'in_memory_store.dart';

// find . -type d -name "build" -size +100cM -exec du -s -k  {}  \;
class DiskUsageRepository {
  final _usageData = InMemoryStore<List<DiskUsageRecord>>([]);

  Stream<List<DiskUsageRecord>> usageDataChanges() => _usageData.stream;
  List<DiskUsageRecord> get currentUser => _usageData.value;

  Future<List<String>> getDiskUsage(String directory) async {
    const executable = 'find';
    final arguments = [
      '.',
      '-type',
      'd',
      '-name',
      'build',
      '-exec',
      'du',
      '-s',
      '-k',
      '{}',
      '+'
    ];
    final process = await Process.run(
      executable,
      arguments,
      workingDirectory: directory,
    );
    if (process.exitCode != 0) {
      debugPrint('stderr: ${process.stderr}');
      return [];
    } else {
      final lines = process.stdout.split('\n');
      return lines;
    }
  }

  DiskUsageRecord? parseDiskUsageLine(String line, String baseDirectory) {
    final pattern = RegExp(r'([0-9-]+) *(.+)$');
    final matchLogLine = pattern.matchAsPrefix(line);
    if (matchLogLine != null) {
      final String? usageInKB = matchLogLine[1];
      final String? pathName = matchLogLine[2];
      if (usageInKB != null && pathName != null) {
        final fullPathName = '$baseDirectory/${pathName.trim()}';
        return DiskUsageRecord(
            directoryPath: fullPathName,
            size: int.parse(usageInKB),
            selected: false);
      }
    }
    return null;
  }

  Future<void> scanDiskUsage(String directoryPath) async {
    _usageData.value = [];
    final discUsageLines = await getDiskUsage(
      directoryPath,
    );
    discUsageLines.forEach((element) {
      debugPrint(element);
    });

    final records = discUsageLines
        .map((line) => parseDiskUsageLine(line, directoryPath))
        .whereType<DiskUsageRecord>()
        .cast<DiskUsageRecord>()
        .toList();
    _usageData.value = records;
  }

  void dispose() => _usageData.close();
}

final diskUsageRepositoryProvider = Provider<DiskUsageRepository>((ref) {
  final diskUsageRepository = DiskUsageRepository();
  ref.onDispose(() => diskUsageRepository.dispose());
  return diskUsageRepository;
});

final diskUsageChangeStreamProvider =
    StreamProvider<List<DiskUsageRecord>>((ref) {
  final authRepository = ref.watch(diskUsageRepositoryProvider);
  return authRepository.usageDataChanges();
});
