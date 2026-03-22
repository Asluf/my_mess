class Income {
  final int? id;
  final int projectId;
  final String title;
  final String? description;
  final double amount;
  final String date;

  Income({
    this.id,
    required this.projectId,
    required this.title,
    this.description,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'title': title,
      'description': description,
      'amount': amount,
      'date': date,
    };
  }

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'],
      projectId: map['project_id'],
      title: map['title'],
      description: map['description'],
      amount: map['amount'].toDouble(),
      date: map['date'],
    );
  }

  Income copyWith({
    int? id,
    int? projectId,
    String? title,
    String? description,
    double? amount,
    String? date,
  }) {
    return Income(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }
}
