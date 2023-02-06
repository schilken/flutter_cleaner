import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../providers/providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appNotifier);
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
                return Center(
                  child: Text('Home ${appState.currentDirectory}'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
