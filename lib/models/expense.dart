class Expense {
  final int? id;
  final int projectId;
  final String title;
  final String? description;
  final double amount;
  final String date;

  Expense({
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

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      projectId: map['project_id'],
      title: map['title'],
      description: map['description'],
      amount: map['amount'].toDouble(),
      date: map['date'],
    );
  }

  Expense copyWith({
    int? id,
    int? projectId,
    String? title,
    String? description,
    double? amount,
    String? date,
  }) {
    return Expense(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }
}
