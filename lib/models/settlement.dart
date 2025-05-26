class Settlement {

  final String fromID;
  final String toID;
  final double amount;

  Settlement({
    required this.fromID,
    required this.toID,
    required this.amount,
  });

  factory Settlement.fromJson(Map<String, dynamic> json) {
    return Settlement(
      fromID: json["fromID"],
      toID: json["toID"],
      amount: (json['amount'] as num).toDouble()
    );
  }

}