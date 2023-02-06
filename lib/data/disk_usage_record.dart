class DiskUsageRecord {
  final String directoryPath;
  final int size;
  final bool selected;
  DiskUsageRecord({
    required this.directoryPath,
    required this.size,
    required this.selected,
  });

  DiskUsageRecord copyWith({
    String? directoryPath,
    int? size,
    bool? selected,
  }) {
    return DiskUsageRecord(
      directoryPath: directoryPath ?? this.directoryPath,
      size: size ?? this.size,
      selected: selected ?? this.selected,
    );
  }

  @override
  bool operator ==(covariant DiskUsageRecord other) {
    if (identical(this, other)) return true;

    return other.directoryPath == directoryPath &&
        other.size == size &&
        other.selected == selected;
  }

  @override
  int get hashCode =>
      directoryPath.hashCode ^ size.hashCode ^ selected.hashCode;
}
