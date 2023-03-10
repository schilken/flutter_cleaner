# flutter_cleaner

This Flutter app for macOS lists all build folders with their size. 
Build folders can grow above 500 MB up to 1 GB!
It's easy to delete all selected folders to make space on the disk.


## Getting started
Create your own version if you have Flutter installed on macOS anyway.

```
git clone github.com/schilken/flutter_cleaner
flutter pub get
flutter build macos
```
You find the built app here: `flutter_cleaner/build/macos/Build/Products/Release/Flutter Cleaner`

<img src="assets_for_readme/FlutterCleaner Screenshot.png"/>

## Download a release from GitHub
Currrently there is only a releas build for [macOS] (https://github.com/schilken/flutter_cleaner/releases/)

## Making of this app or similar tools
I generated a starter project using mason. If you want to create a similar tool you can generate a starter project like so:
- Open https://brickhub.dev
- Search for macosui_tool_starter
- Follow the steps on the Usage page

## Credits
Several ideas are taken from https://github.com/bizz84/complete-flutter-course, a great source for learning advanced Flutter created by Andrea Bizzotto (bizz84). Also, thanks to Reuben Turner (GroovinChip) for his great package at https://github.com/GroovinChip/macos_ui