class Ticket {
  final int? ticketID;
  final int? customerID;
  final int? sessionID;
  final int? sessionSeatID;
  final double? price;

  Ticket({
    this.ticketID,
    this.customerID,
    this.sessionID,
    this.sessionSeatID,
    this.price,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      ticketID: json['ticketID'] as int?,
      customerID: json['customerID'] as int?,
      sessionID: json['sessionID'] as int?,
      sessionSeatID: json['sessionSeatID'] as int?,
      price: (json['price'] as num?)?.toDouble(),
    );
  }

  // Optional: JSON'a dönüştürmek için toJson metodu
  Map<String, dynamic> toJson() {
    return {
      'customerID': customerID,
      'sessionID': sessionID,
      'sessionSeatID': sessionSeatID,
      'price': price,
    };
  }
}