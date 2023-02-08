// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bot_toast/bot_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cleaner/data/disk_usage_record.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import 'package:flutter_cleaner/extensions.dart';

import '../async_value_widget.dart';
import '../providers/providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appNotifier);
    final diskUsageAsyncValue = ref.watch(diskUsageNotifier);

    return Builder(
      builder: (context) {
        return MacosScaffold(
          toolBar: ToolBar(
            leading: MacosIconButton(
              icon: const MacosIcon(
                CupertinoIcons.sidebar_left,
                size: 40,
                color: CupertinoColors.black,
              ),
              onPressed: () {
                MacosWindowScope.of(context).toggleSidebar();
              },
            ),
            title: const Text('Scan Result'),
            titleWidth: 100,
            actions: [
              ToolBarPullDownButton(
                label: "Actions",
                icon: CupertinoIcons.ellipsis_circle,
                tooltipMessage: "Perform tasks with the selected items",
                items: [
                  MacosPulldownMenuItem(
                    title: const Text("Choose Folder"),
                    onTap: () async {
                      String? selectedDirectory =
                          await FilePicker.platform.getDirectoryPath();
                      if (selectedDirectory != null) {
                        ref.read(appNotifier.notifier).setCurrentDirectory(
                            directoryPath: selectedDirectory);
                        ref
                            .read(diskUsageNotifier.notifier)
                            .scan(selectedDirectory);
                      }
                    },
                  ),
                  MacosPulldownMenuItem(
                    title: const Text("Scan Directory"),
                    onTap: () {
                      ref
                          .read(diskUsageNotifier.notifier)
                          .scan(appState.currentDirectory);
                    },
                  ),
                ],
              ),
            ],
          ),
          children: [
            ContentArea(
              builder: (context) {
                return Column(
                  children: [
                    ScanPageHeader(ref: ref),
                    Expanded(
                      child: diskUsageAsyncValue.when(
                          error: (e, st) =>
                              Center(child: ErrorMessageWidget(e.toString())),
                          loading: () =>
                              const Center(child: ProgressCircle(radius: 30)),
                          data: (records) {
                            if (records == null) {
                              return const Center(
                                  child: Text('Not yet scanned'));
                            }
                            if (records.isEmpty) {
                              return const Center(
                                  child: Text('No directories found'));
                            }
                            return RecordsView(records, ref);
                          }),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class RecordsView extends StatelessWidget {
  const RecordsView(
    this.records,
    this.ref, {
    super.key,
  });
  final List<DiskUsageRecord> records;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (_, index) {
        final record = records[index];
        return Material(
          child: CheckboxListTile(
            value: record.isSelected,
            title: Text(
              record.directoryPath,
            ),
            subtitle: Text(record.size.toMegaBytes),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (bool? value) {
              ref.read(diskUsageNotifier.notifier).selectRecord(index, value);
            },
          ),
        );
      },
    );
  }
}

class ScanPageHeader extends StatelessWidget {
  const ScanPageHeader({
    super.key,
    required this.ref,
  });

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appNotifier);
    final diskUsageAsyncValue = ref.watch(diskUsageNotifier);
    final selectedRecordCount = diskUsageAsyncValue.maybeMap<int>(
        data: (data) {
          final records = data.value ?? [];
          return records.where((r) => r.isSelected).length;
        },
        orElse: () => 0);
    final totalSize = diskUsageAsyncValue.maybeMap<int>(
        data: (data) {
          final records = data.value ?? [];
          return records.fold(0, (sum, r) => sum + r.size);
        },
        orElse: () => 0);

    final selectedSize = diskUsageAsyncValue.maybeMap<int>(
        data: (data) {
          final records = data.value ?? [];
          return records
              .where((r) => r.isSelected)
              .fold(0, (sum, r) => sum + r.size);
        },
        orElse: () => 0);
    return Container(
      color: Colors.blueGrey[100],
      padding: const EdgeInsets.fromLTRB(12, 20, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text('Scanned Directory: '),
          Expanded(child: Text(appState.currentDirectory)),
          const SizedBox(width: 8),
          Text('${totalSize.toMegaBytes} - ${selectedSize.toMegaBytes}'),
          const SizedBox(width: 8),
          PushButton(
            buttonSize: ButtonSize.large,
            isSecondary: true,
            color: Colors.white,
            onPressed: selectedRecordCount == 0
                ? null
                : () async {
                    final result = await ref
                        .read(diskUsageNotifier.notifier)
                        .deleteSelectedDirectories();
                    BotToast.showText(
                      text: result,
                      duration: const Duration(seconds: 3),
                      align: const Alignment(0, 0.3),
                    );
                  },
            child: Text('Delete $selectedRecordCount Directories'),
          ),
        ],
      ),
    );
  }
}
