class DiskUsageRecord {
  final String directoryPath;
  final int size;
  final bool isSelected;
  DiskUsageRecord({
    required this.directoryPath,
    required this.size,
    required this.isSelected,
  });

  DiskUsageRecord copyWith({
    String? directoryPath,
    int? size,
    bool? isSelected,
  }) {
    return DiskUsageRecord(
      directoryPath: directoryPath ?? this.directoryPath,
      size: size ?? this.size,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(covariant DiskUsageRecord other) {
    if (identical(this, other)) return true;

    return other.directoryPath == directoryPath &&
        other.size == size &&
        other.isSelected == isSelected;
  }

  @override
  int get hashCode =>
      directoryPath.hashCode ^ size.hashCode ^ isSelected.hashCode;
}
