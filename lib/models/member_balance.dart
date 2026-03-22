class MemberBalance {
  final int memberId;
  final String memberName;
  final int colorIndex;
  final double paid;
  final double share;
  final double balance;

  MemberBalance({
    required this.memberId,
    required this.memberName,
    required this.colorIndex,
    required this.paid,
    required this.share,
    required this.balance,
  });
}

class Settlement {
  final int fromId;
  final String fromName;
  final int toId;
  final String toName;
  final double amount;

  Settlement({
    required this.fromId,
    required this.fromName,
    required this.toId,
    required this.toName,
    required this.amount,
  });
}
