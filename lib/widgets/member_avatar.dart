import 'package:flutter/material.dart';
import '../models/member.dart';

class MemberAvatar extends StatelessWidget {
  final Member member;
  final double radius;

  const MemberAvatar({
    super.key,
    required this.member,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: member.avatarColor,
      child: Text(
        member.initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.9,
        ),
      ),
    );
  }
}
