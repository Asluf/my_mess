class MessProject {
  final int? id;
  final String name;
  final DateTime createdAt;

  MessProject({
    this.id,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'created_at': createdAt.toIso8601String(),
      };

  factory MessProject.fromMap(Map<String, dynamic> map) => MessProject(
        id: map['id'] as int?,
        name: map['name'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  MessProject copyWith({int? id, String? name, DateTime? createdAt}) =>
      MessProject(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
}
