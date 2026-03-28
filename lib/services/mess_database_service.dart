import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/mess_project.dart';
import '../models/member.dart';
import '../models/mess_expense.dart';

class MessDatabaseService {
  MessDatabaseService._();
  static final MessDatabaseService instance = MessDatabaseService._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'my_mess.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE mess_projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        color_index INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES mess_projects (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE mess_expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        paid_by INTEGER NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        split_type TEXT NOT NULL DEFAULT 'equal',
        FOREIGN KEY (project_id) REFERENCES mess_projects (id) ON DELETE CASCADE,
        FOREIGN KEY (paid_by) REFERENCES members (id) ON DELETE CASCADE
      )
    ''');
  }

  // ── Projects ──

  Future<int> insertProject(MessProject project) async {
    final db = await database;
    return db.insert('mess_projects', project.toMap()..remove('id'));
  }

  Future<List<MessProject>> getProjects() async {
    final db = await database;
    final maps = await db.query('mess_projects', orderBy: 'created_at DESC');
    return maps.map((m) => MessProject.fromMap(m)).toList();
  }

  Future<MessProject?> getProject(int id) async {
    final db = await database;
    final maps =
        await db.query('mess_projects', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return MessProject.fromMap(maps.first);
  }

  Future<int> updateProject(MessProject project) async {
    final db = await database;
    return db.update(
      'mess_projects',
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  Future<int> deleteProject(int id) async {
    final db = await database;
    return db.delete('mess_projects', where: 'id = ?', whereArgs: [id]);
  }

  /// Fetches projects with member counts and total expenses in a single optimized query.
  /// This replaces the N+1 query pattern and significantly improves performance.
  /// Note: avoid joining members and expenses in one query because it can duplicate rows,
  /// causing SUM(expense) to be multiplied by member count.
  Future<List<Map<String, dynamic>>> getProjectsWithStats() async {
    final db = await database;
    return db.rawQuery('''
      SELECT
        p.id,
        p.name,
        p.created_at,
        (SELECT COUNT(*) FROM members m WHERE m.project_id = p.id) AS member_count,
        (SELECT COALESCE(SUM(amount), 0) FROM mess_expenses e WHERE e.project_id = p.id) AS total_expenses
      FROM mess_projects p
      ORDER BY p.created_at DESC
    ''');
  }

  // ── Members ──

  Future<int> insertMember(Member member) async {
    final db = await database;
    return db.insert('members', member.toMap()..remove('id'));
  }

  Future<List<Member>> getMembers(int projectId) async {
    final db = await database;
    final maps = await db.query(
      'members',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'created_at ASC',
    );
    return maps.map((m) => Member.fromMap(m)).toList();
  }

  Future<int> getMemberCount(int projectId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM members WHERE project_id = ?',
      [projectId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> updateMember(Member member) async {
    final db = await database;
    return db.update(
      'members',
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  Future<int> deleteMember(int id) async {
    final db = await database;
    return db.delete('members', where: 'id = ?', whereArgs: [id]);
  }

  // ── Expenses ──

  Future<int> insertExpense(MessExpense expense) async {
    final db = await database;
    return db.insert('mess_expenses', expense.toMap()..remove('id'));
  }

  Future<List<MessExpense>> getExpenses(int projectId) async {
    final db = await database;
    final maps = await db.query(
      'mess_expenses',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'date DESC',
    );
    return maps.map((m) => MessExpense.fromMap(m)).toList();
  }

  Future<double> getTotalExpenses(int projectId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM mess_expenses WHERE project_id = ?',
      [projectId],
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<int> updateExpense(MessExpense expense) async {
    final db = await database;
    return db.update(
      'mess_expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return db.delete('mess_expenses', where: 'id = ?', whereArgs: [id]);
  }
}
