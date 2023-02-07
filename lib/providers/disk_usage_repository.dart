// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;

import '../data/disk_usage_record.dart';

// find . -type d -name "build" -size +100cM -exec du -s -k  {}  \;
class DiskUsageRepository {

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

  DiskUsageRecord? parseDiskUsageLine(String line) {
    final pattern = RegExp(r'([0-9-]+) *(.+)$');
    final matchLogLine = pattern.matchAsPrefix(line);
    if (matchLogLine != null) {
      final String? usageInKB = matchLogLine[1];
      final String? pathName = matchLogLine[2];
      if (usageInKB != null && pathName != null) {
        return DiskUsageRecord(
            directoryPath: pathName.trim().replaceFirst('./', ''),
            size: int.parse(usageInKB),
            isSelected: false);
      }
    }
    return null;
  }

  Future<List<DiskUsageRecord>> scanDiskUsage(String directoryPath) async {
    final discUsageLines = await getDiskUsage(
      directoryPath,
    );
    // discUsageLines.forEach((element) {
    //   debugPrint(element);
    // });
    final records = discUsageLines
        .map((line) => parseDiskUsageLine(line))
        .whereType<DiskUsageRecord>()
        .cast<DiskUsageRecord>()
        .toList();
    return records..sort((r1, r2) => r2.size.compareTo(r1.size));
  }

}

final diskUsageRepositoryProvider = Provider<DiskUsageRepository>((ref) {
  final diskUsageRepository = DiskUsageRepository();
  return diskUsageRepository;
});
