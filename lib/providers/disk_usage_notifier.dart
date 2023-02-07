import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/disk_usage_record.dart';
import 'disk_usage_repository.dart';

typedef AsyncResult = AsyncValue<List<DiskUsageRecord>?>;

class DiskUsageNotifier extends AsyncNotifier<List<DiskUsageRecord>?> {
  DiskUsageNotifier();

  late DiskUsageRepository _diskUsageRepository;

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
  }

  bool get isLoading => state.isLoading;
}

final diskUsageNotifier =
    AsyncNotifierProvider<DiskUsageNotifier, List<DiskUsageRecord>?>(() {
  return DiskUsageNotifier();
});
