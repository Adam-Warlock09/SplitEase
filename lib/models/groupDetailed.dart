import 'package:split_ease/models/user.dart';

class GroupDetailed {

  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User createdBy;
  final List<User> members;

  GroupDetailed({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.members,
  });

  factory GroupDetailed.fromJson(Map<String, dynamic> json) {

    return GroupDetailed(
      id: json["id"],
      name: json["name"],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdBy: User.fromJson(json['createdBy']),
      members: (json['members'] as List<dynamic>).map((memberJson) => User.fromJson(memberJson)).toList(),
    );

  }

}