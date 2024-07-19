class PlateInfo {
  final String plateNumber;
  final DateTime entryTime;
  final DateTime? exitTime;

  PlateInfo({
    required this.plateNumber,
    required this.entryTime,
    this.exitTime,
  });

  PlateInfo copyWith({
    String? plateNumber,
    DateTime? entryTime,
    DateTime? exitTime,
  }) {
    return PlateInfo(
      plateNumber: plateNumber ?? this.plateNumber,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
    );
  }
}
