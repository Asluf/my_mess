import 'package:flutter/material.dart';
import '../models/mess_project.dart';
import '../models/member.dart';
import '../services/mess_database_service.dart';

class ProjectProvider extends ChangeNotifier {
  final _db = MessDatabaseService.instance;

  List<MessProject> _projects = [];
  List<MessProject> get projects => _projects;

  bool _loading = false;
  bool get loading => _loading;

  // ── Project-level member counts (for list screen) ──
  final Map<int, int> _memberCounts = {};
  int memberCountFor(int projectId) => _memberCounts[projectId] ?? 0;

  final Map<int, double> _totalExpenses = {};
  double totalExpensesFor(int projectId) => _totalExpenses[projectId] ?? 0;

  Future<void> loadProjects() async {
    _loading = true;
    notifyListeners();

    _projects = await _db.getProjects();

    for (final p in _projects) {
      _memberCounts[p.id!] = await _db.getMemberCount(p.id!);
      _totalExpenses[p.id!] = await _db.getTotalExpenses(p.id!);
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> addProject(String name) async {
    final project = MessProject(name: name, createdAt: DateTime.now());
    await _db.insertProject(project);
    await loadProjects();
  }

  Future<void> deleteProject(int id) async {
    await _db.deleteProject(id);
    _projects.removeWhere((p) => p.id == id);
    _memberCounts.remove(id);
    _totalExpenses.remove(id);
    notifyListeners();
  }

  // ── Members for a specific project ──

  List<Member> _members = [];
  List<Member> get members => _members;

  Future<void> loadMembers(int projectId) async {
    _members = await _db.getMembers(projectId);
    notifyListeners();
  }

  Future<void> addMember(int projectId, String name) async {
    final colorIndex = _members.length % Member.avatarColors.length;
    final member = Member(
      projectId: projectId,
      name: name,
      colorIndex: colorIndex,
      createdAt: DateTime.now(),
    );
    await _db.insertMember(member);
    await loadMembers(projectId);
  }

  Future<void> updateMember(Member member) async {
    await _db.updateMember(member);
    await loadMembers(member.projectId);
  }

  Future<void> deleteMember(int projectId, int memberId) async {
    await _db.deleteMember(memberId);
    await loadMembers(projectId);
  }
}
