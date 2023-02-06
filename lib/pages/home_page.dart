import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../async_value_widget.dart';
import '../data/disk_usage_record.dart';
import '../data/disk_usage_repository.dart';
import '../providers/providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appNotifier);
    final diskUsageChange = ref.watch(diskUsageChangeStreamProvider); 
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
            title: Text('Home Version ${appState.appVersion}'),
            titleWidth: 250,
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
                      }
                    },
                  ),
                  MacosPulldownMenuItem(
                    title: const Text("Scan Directory"),
                    onTap: () {
                      ref.read(appNotifier.notifier).scanDirectory();
                    },
                  ),
                ],
              ),
            ],
          ),
          children: [
            ContentArea(
              builder: (context) {
                return AsyncValueWidget<List<DiskUsageRecord>>(
                  value: diskUsageChange,
                  data: (records) => records.isEmpty
                      ? Center(
                          child: Text(
                            'No build folder found',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        )
                      : ListView.builder(
                          itemCount: records.length,
                          itemBuilder: (_, index) {
                            final record = records[index];
                            return Material(
                              child: ListTile(
                                title: Text(
                                  record.directoryPath,
                                ),
                              ),
                            );
                          },
                        ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
