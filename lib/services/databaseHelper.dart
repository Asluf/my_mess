import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/project.dart';
import '../models/expense.dart';
import '../models/income.dart';

class DatabaseHelper {
  static const _databaseName = "business_tracker.db";
  static const _databaseVersion = 1;

  // Table names
  static const projectsTable = 'projects';
  static const expensesTable = 'expenses';
  static const incomesTable = 'incomes';

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Create projects table
    await db.execute('''
      CREATE TABLE $projectsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Create expenses table
    await db.execute('''
      CREATE TABLE $expensesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES $projectsTable (id) ON DELETE CASCADE
      )
    ''');

    // Create incomes table
    await db.execute('''
      CREATE TABLE $incomesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES $projectsTable (id) ON DELETE CASCADE
      )
    ''');
  }

  // Project CRUD operations
  Future<int> insertProject(Project project) async {
    Database db = await instance.database;
    return await db.insert(projectsTable, project.toMap());
  }

  Future<List<Project>> getAllProjects() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
        projectsTable,
      orderBy: 'id DESC'
    );
    return List.generate(maps.length, (i) => Project.fromMap(maps[i]));
  }

  Future<Project?> getProject(int id) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      projectsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Project.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateProject(Project project) async {
    Database db = await instance.database;
    return await db.update(
      projectsTable,
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  Future<int> deleteProject(int id) async {
    Database db = await instance.database;
    return await db.delete(
      projectsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Expense CRUD operations
  Future<int> insertExpense(Expense expense) async {
    Database db = await instance.database;
    return await db.insert(expensesTable, expense.toMap());
  }

  Future<List<Expense>> getExpensesByProject(int projectId) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      expensesTable,
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<double> getTotalExpensesByProject(int projectId) async {
    Database db = await instance.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM $expensesTable WHERE project_id = ?',
      [projectId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> deleteExpense(int id) async {
    Database db = await instance.database;
    return await db.delete(
      expensesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Income CRUD operations
  Future<int> insertIncome(Income income) async {
    Database db = await instance.database;
    return await db.insert(incomesTable, income.toMap());
  }

  Future<List<Income>> getIncomesByProject(int projectId) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      incomesTable,
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Income.fromMap(maps[i]));
  }

  Future<double> getTotalIncomesByProject(int projectId) async {
    Database db = await instance.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM $incomesTable WHERE project_id = ?',
      [projectId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> deleteIncome(int id) async {
    Database db = await instance.database;
    return await db.delete(
      incomesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get project summary with totals
  Future<Map<String, dynamic>> getProjectSummary(int projectId) async {
    final totalIncome = await getTotalIncomesByProject(projectId);
    final totalExpense = await getTotalExpensesByProject(projectId);
    final profit = totalIncome - totalExpense;

    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'profit': profit,
    };
  }
}
