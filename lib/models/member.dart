import 'package:flutter/material.dart';

class Member {
  final int? id;
  final int projectId;
  final String name;
  final int colorIndex;
  final DateTime createdAt;

  Member({
    this.id,
    required this.projectId,
    required this.name,
    this.colorIndex = 0,
    required this.createdAt,
  });

  static const List<Color> avatarColors = [
    Color(0xFFE57373),
    Color(0xFF81C784),
    Color(0xFF64B5F6),
    Color(0xFFFFB74D),
    Color(0xFFBA68C8),
    Color(0xFF4DB6AC),
    Color(0xFFFF8A65),
    Color(0xFFA1887F),
  ];

  Color get avatarColor => avatarColors[colorIndex % avatarColors.length];

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  Map<String, dynamic> toMap() => {
        'id': id,
        'project_id': projectId,
        'name': name,
        'color_index': colorIndex,
        'created_at': createdAt.toIso8601String(),
      };

  factory Member.fromMap(Map<String, dynamic> map) => Member(
        id: map['id'] as int?,
        projectId: map['project_id'] as int,
        name: map['name'] as String,
        colorIndex: map['color_index'] as int? ?? 0,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Member copyWith({
    int? id,
    int? projectId,
    String? name,
    int? colorIndex,
    DateTime? createdAt,
  }) =>
      Member(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        name: name ?? this.name,
        colorIndex: colorIndex ?? this.colorIndex,
        createdAt: createdAt ?? this.createdAt,
      );
}
