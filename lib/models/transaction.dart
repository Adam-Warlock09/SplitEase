class Transaction {
  final String id;
  final String groupID;
  final String? notes;
  final DateTime createdAt;
  final double amount;
  final String fromUser;
  final String toUser;

  Transaction({
     required this.id,
    required this.groupID,
    this.notes,
    required this.createdAt,
    required this.amount,
    required this.fromUser,
    required this.toUser,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json["id"],
      groupID: json["groupId"],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      amount: (json['amount'] as num).toDouble(),
      fromUser: json['fromUser'],
      toUser: json['toUser'],
    );
  }
  
}
