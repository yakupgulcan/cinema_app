class SessionSeat {
  final int? sessionSeatID;
  final int? sessionID;
  final int? seatID;
  final bool? isAvailable;

  SessionSeat({
    this.sessionSeatID,
    this.sessionID,
    this.seatID,
    this.isAvailable,
  });

  factory SessionSeat.fromJson(Map<String, dynamic> json) {
    return SessionSeat(
      sessionSeatID: json['sessionSeatID'] as int?,
      sessionID: json['sessionID'] as int?,
      seatID: json['seatID'] as int?,
      isAvailable: json['isAvailable'] != null ? json['isAvailable'] == 1 : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionSeatID': sessionSeatID,
      'sessionID': sessionID,
      'seatID': seatID,
      'isAvailable': isAvailable != null ? (isAvailable! ? 1 : 0) : null,
    };
  }
}