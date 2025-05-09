class Session {
  final int? sessionID;
  final int? movieID;
  final int? hallID;
  final String? date;
  final String? sessionNo;
  final String? status;

  Session({
    this.sessionID,
    this.movieID,
    this.hallID,
    this.date,
    this.sessionNo,
    this.status,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionID: json['sessionID'] as int?,
      movieID: json['movieID'] as int?,
      hallID: json['hallID'] as int?,
      date: json['date'] as String?,
      sessionNo: json['sessionNo'] as String?,
      status: json['status'] as String?,
    );
  }
}