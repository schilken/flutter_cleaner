import 'package:flutter_cleaner/data/disk_usage_record.dart';
import 'package:flutter_cleaner/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeDiskUsageRepository implements DiskUsageRepository {
  @override
  String? currentDirectory;

  @override
  Future<List<DiskUsageRecord>> scanDiskUsage(String directoryPath) async {
    currentDirectory = directoryPath;
    return const [
      DiskUsageRecord(directoryPath: 'a', size: 1, isSelected: false),
      DiskUsageRecord(directoryPath: 'b', size: 2, isSelected: false),
    ];
  }
}

void main() {
  late ProviderContainer container;
  late DiskUsageNotifier notifier;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        diskUsageRepositoryProvider.overrideWithValue(
          _FakeDiskUsageRepository(),
        ),
      ],
    );
    notifier = container.read(diskUsageNotifierProvider.notifier);
    await notifier.scan();
  });

  tearDown(() => container.dispose());

  test('selecting a record notifies listeners', () {
    var notifications = 0;
    container.listen(diskUsageNotifierProvider, (_, __) => notifications++);

    notifier.selectRecord(0, value: true);

    expect(notifications, 1);
  });

  test('selecting multiple records notifies listeners each time', () {
    var notifications = 0;
    container.listen(diskUsageNotifierProvider, (_, __) => notifications++);

    notifier.selectRecord(0, value: true);
    notifier.selectRecord(1, value: true);

    expect(notifications, 2);
    final records = container.read(diskUsageNotifierProvider).value!;
    expect(records.where((r) => r.isSelected).length, 2);
  });

  test('selecting all records notifies listeners', () {
    var notifications = 0;
    container.listen(diskUsageNotifierProvider, (_, __) => notifications++);

    notifier.selectAll(isSelected: true);

    expect(notifications, 1);
    final records = container.read(diskUsageNotifierProvider).value!;
    expect(records.where((r) => r.isSelected).length, 2);
  });
}
