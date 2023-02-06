# flutter_cleaner

A starter Flutter app for macOS with `macos_ui`.

## Getting Started

This project is a starting point for a Flutter tool targeting macOS.

It provides a Flutter application that:
* Targets macOS (support for other platforms can be added manually)
* Has these packages pre-installed
  * `macos_ui` 
  * `flutter_hooks`
  * `hooks_riverpod`
  * `shared_preferences`
  * `file_picker`
  * `pubspec_parse`
* Builds basic UI based on the latest version of `macos_ui` 
* Provides a `ToolBarPullDownButton` in the `ToolBar` with two menu items
 * `Choose Folder` which opens a FilePicker
 * `Scan Directory`which calls a method on `AppNotifier`
* Reads the current version from the pubspec.yaml and provides it in the `AppState`

