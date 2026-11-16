import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('SpaceNews.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final pathDB = join(dbPath, fileName);

    return await openDatabase(pathDB, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        salt TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // Membuat salt acak untuk setiap pengguna
  String _generateSalt() {
    final random = Random.secure();

    return List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  // Mengubah password menjadi hash
  String _hashPassword(String password, String salt) {
    return sha256.convert(utf8.encode('$salt:$password')).toString();
  }

  // Register pengguna baru
  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await database;

    final normalizedEmail = email.trim().toLowerCase();

    final existingUser = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );

    if (existingUser.isNotEmpty) {
      return false;
    }

    final salt = _generateSalt();
    final passwordHash = _hashPassword(password, salt);

    await db.insert('users', {
      'name': name.trim(),
      'email': normalizedEmail,
      'password_hash': passwordHash,
      'salt': salt,
      'created_at': DateTime.now().toIso8601String(),
    });

    return true;
  }

  // Login pengguna
  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    final db = await database;

    final normalizedEmail = email.trim().toLowerCase();

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    final user = result.first;

    final storedHash = user['password_hash'] as String;
    final salt = user['salt'] as String;

    final inputHash = _hashPassword(password, salt);

    if (storedHash != inputHash) {
      return null;
    }

    return {'id': user['id'], 'name': user['name'], 'email': user['email']};
  }
}
