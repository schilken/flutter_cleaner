// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_cleaner/data/disk_usage_record.dart';
import 'package:flutter_cleaner/main.dart';
import 'package:flutter_cleaner/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeDiskUsageRepository implements DiskUsageRepository {
  @override
  String? currentDirectory;

  @override
  Future<List<DiskUsageRecord>> scanDiskUsage(String directoryPath) async {
    currentDirectory = directoryPath;
    return [];
  }
}

void main() {
  testWidgets('App is built with a MacosWindow parent widget', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          diskUsageRepositoryProvider.overrideWithValue(
            _FakeDiskUsageRepository(),
          ),
        ],
        child: const MainApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.byType(MacosWindow), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 1));
  });
}
