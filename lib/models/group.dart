class Group {

  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> members;
  final List<String> expenses;
  final String createdBy;

  Group({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.members,
    required this.expenses,
    required this.createdBy,
  });

  factory Group.fromJson(Map<String, dynamic> json) {

    return Group(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      members: List<String>.from(json['members']),
      expenses: List<String>.from(json["expenses"] ?? []),
      createdBy: json['createdBy']
    );

  }

  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'members': members,
      'expenses': expenses,
      'createdBy': createdBy,
    };
    
  }

}