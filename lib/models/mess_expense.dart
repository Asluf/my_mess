class MessExpense {
  final int? id;
  final int projectId;
  final int paidBy;
  final double amount;
  final String description;
  final DateTime date;
  final String splitType;

  MessExpense({
    this.id,
    required this.projectId,
    required this.paidBy,
    required this.amount,
    required this.description,
    required this.date,
    this.splitType = 'equal',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'project_id': projectId,
        'paid_by': paidBy,
        'amount': amount,
        'description': description,
        'date': date.toIso8601String(),
        'split_type': splitType,
      };

  factory MessExpense.fromMap(Map<String, dynamic> map) => MessExpense(
        id: map['id'] as int?,
        projectId: map['project_id'] as int,
        paidBy: map['paid_by'] as int,
        amount: (map['amount'] as num).toDouble(),
        description: map['description'] as String,
        date: DateTime.parse(map['date'] as String),
        splitType: map['split_type'] as String? ?? 'equal',
      );

  MessExpense copyWith({
    int? id,
    int? projectId,
    int? paidBy,
    double? amount,
    String? description,
    DateTime? date,
    String? splitType,
  }) =>
      MessExpense(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        paidBy: paidBy ?? this.paidBy,
        amount: amount ?? this.amount,
        description: description ?? this.description,
        date: date ?? this.date,
        splitType: splitType ?? this.splitType,
      );
}
