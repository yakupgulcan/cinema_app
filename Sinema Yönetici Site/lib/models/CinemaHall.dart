class Hall {
  final int? hallID;
  final String? hallName;
  final int? capacity;
  final String? hallType;

  Hall({
    this.hallID,
    this.hallName,
    this.capacity,
    this.hallType,
  });

  factory Hall.fromJson(Map<String, dynamic> json) {
    return Hall(
      hallID: json['hallID'] as int?,
      hallName: json['hallName'] as String?,
      capacity: json['capacity'] as int?,
      hallType: json['hallType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hallID': hallID,
      'hallName': hallName,
      'capacity': capacity,
      'hallType': hallType,
    };
  }
}