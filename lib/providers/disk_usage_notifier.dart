import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    state = const AsyncValue.loading();
    state = await AsyncResult.guard(
      () => _diskUsageRepository.scanDiskUsage(directory),
    );
    _records.clear();
    _records.addAll(state.value ?? []);
  }

  bool get isLoading => state.isLoading;

  void selectRecord(int index, bool? value) {
    _records[index] = _records[index].copyWith(selected: value);
    state = AsyncValue.data(_records);
  }
}

final diskUsageNotifier =
    AsyncNotifierProvider<DiskUsageNotifier, List<DiskUsageRecord>?>(() {
  return DiskUsageNotifier();
});
