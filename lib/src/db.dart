import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:notes/src/note/note.dart';
import 'package:notes/src/settings/setting.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

const String _notesTable = 'notes';
const String _settingsTable = 'settings';

class Db {
  static final Db _db = Db._internal();
  factory Db() => _db;
  Db._internal();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path;
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      path = 'my_web_web.db';
    } else if (Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      path = inMemoryDatabasePath;
    } else {
      path = join(await getDatabasesPath(), 'notes_database.db');
    }
    return await databaseFactory.openDatabase(path,
        options: OpenDatabaseOptions(
          onCreate: (Database db, int version) => _createTables(db),
          version: 1,
        ));
  }

  static Future<void> _createTables(Database db) async {
    await db.execute(
        'CREATE TABLE $_notesTable(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title TEXT, content TEXT, favorite INTEGER DEFAULT 0)');
    await db.execute(
        'CREATE TABLE $_settingsTable(setting TEXT PRIMARY KEY, value TEXT)');
  }

  Future<int> insertNote(
      {required String title, required String content}) async {
    final db = await _db.database;
    return await db.insert(_notesTable, {'title': title, 'content': content},
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<Note>> getNotes() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps =
        await db.query(_notesTable, orderBy: 'favorite DESC, id ASC');
    return List.generate(maps.length, (i) {
      return Note(
        id: maps[i]['id'],
        title: maps[i]['title'],
        content: maps[i]['content'],
        favorite: maps[i]['favorite'] == 1,
      );
    });
  }

  Future<int> deleteNoteById(int id) async {
    final db = await _db.database;
    return await db.delete(_notesTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateNoteById(
      {required int id, required String title, required String content}) async {
    final db = await _db.database;
    return await db.update(_notesTable, {'title': title, 'content': content},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<Note?> getNoteById(int id) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps =
        await db.query(_notesTable, where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) {
      return null;
    }
    return Note(
      id: maps[0]['id'],
      title: maps[0]['title'],
      content: maps[0]['content'],
      favorite: maps[0]['favorite'] == 1,
    );
  }

  Future<int> favoriteNoteById(int id) async {
    final db = await _db.database;
    final note = await getNoteById(id);
    if (note == null) {
      return 0;
    }
    return await db.update(_notesTable, {'favorite': note.favorite ? 0 : 1},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertOrUpdateSetting(
      {required String setting, required String value}) async {
    final db = await _db.database;
    return db.insert(_settingsTable, {'setting': setting, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Setting?> getSetting(String setting) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db
        .query(_settingsTable, where: 'setting = ?', whereArgs: [setting]);
    if (maps.isEmpty) {
      return null;
    }
    return Setting(
      setting: maps[0]['setting'],
      value: maps[0]['value'],
    );
  }
}
