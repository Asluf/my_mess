class Project {
  final int? id;
  final String name;
  final String? description;
  final String createdAt;

  Project({
    this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      createdAt: map['created_at'],
    );
  }

  Project copyWith({
    int? id,
    String? name,
    String? description,
    String? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
