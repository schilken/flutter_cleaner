import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../providers/app_notifier.dart';
import 'home_page.dart';

class MainView extends ConsumerStatefulWidget {
  const MainView({super.key});

  @override
  ConsumerState<MainView> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appNotifier);
    return MacosWindow(
      sidebar: Sidebar(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
        ),
        minWidth: 200,
        bottom: MacosListTile(
          leading: const MacosIcon(CupertinoIcons.app_badge),
          title: const Text('Flutter Cleaner'),
          subtitle: Text('Version ${appState.appVersion}'),
        ),
        builder: (context, scrollController) => SidebarItems(
          currentIndex: _pageIndex,
          onChanged: (index) {
            setState(() => _pageIndex = index);
          },
          items: const [
            SidebarItem(
              leading: MacosIcon(CupertinoIcons.home),
              label: Text('Result Page'),
            ),
            // SidebarItem(
            //   leading: MacosIcon(CupertinoIcons.gear),
            //   label: Text('Settings'),
            // ),
          ],
        ),
      ),
      child: IndexedStack(
        index: _pageIndex,
        children: const [
          HomePage(),
//          SettingsPage(),
        ],
      ),
    );
  }
}
