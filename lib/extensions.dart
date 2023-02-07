extension IntInMB on int {
  String get toMegaBytes {
    final mb = this ~/ 1024;
    if (mb > 0) {
      return '$mb MB';
    }
    return '$this kB';
  }
}
