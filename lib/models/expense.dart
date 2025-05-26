class Expense {
  final String? id;
  final String groupID;
  final String title;
  final String? notes;
  final DateTime? createdAt;
  final double amount;
  final String paidBy;
  final String splitType;
  final Map<String, double> splits;

  Expense({
    this.id,
    required this.groupID,
    required this.title,
    this.notes,
    this.createdAt,
    required this.amount,
    required this.paidBy,
    required this.splitType,
    required this.splits,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json["id"],
      groupID: json["groupId"],
      title: json["title"],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      amount: (json['amount'] as num).toDouble(),
      paidBy: json['paidBy'],
      splitType: json['splitType'],
      splits: (json['splits'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    if (notes != null) {
      return {
        'groupId': groupID,
        'title': title,
        'notes': notes,
        'amount': amount,
        'paidBy': paidBy,
        'splitType': splitType,
        'splits': splits,
      };
    } else {
      return {
        'groupId': groupID,
        'title': title,
        'amount': amount,
        'paidBy': paidBy,
        'splitType': splitType,
        'splits': splits,
      };
    }
  }

}
