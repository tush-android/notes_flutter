import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'notes_dbthree');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT,
            date TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE todo_lists(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT
          )
        ''');

        
      },
    );
  }

  // NOTES CRUD

  Future<int> insertNote(String title, String content) async {
    final dbob = await db;
    return await dbob.insert('notes', {
      'title': title,
      'content': content,
      'date': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getNotes({String query = ''}) async {
    final dbo = await db;
    //return await dbo.query('notes', orderBy: 'date DESC');
    if (query.isEmpty) {
      // No query, fetch all notes
      return await dbo.query('notes', orderBy: 'date DESC');
    } else {
      // Filter notes based on query
      return await dbo.query(
        'notes',
        where: 'title LIKE ? OR content LIKE ?',  // Searching in title and content
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'date DESC',
      );
    }
  }

  Future<int> updateNote(int id, String title, String content) async {
    final d = await db;
    return await d.update(
      'notes',
      {
        'title': title,
        'content': content,
        'date': DateTime.now().toIso8601String()
      },
      where: 'id=?',
      whereArgs: [id],
    );
  }

  Future<int> deleteNote(int id) async {
    final d = await db;
    return await d.delete('notes', where: 'id=?', whereArgs: [id]);
  }


}
