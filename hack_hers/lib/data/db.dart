import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'models.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._();
  AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'hack_hers.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE profiles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            relationship TEXT NOT NULL,
            photoPath TEXT,
            tags TEXT,
            note TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            profileId INTEGER,
            dateTime TEXT NOT NULL,
            title TEXT NOT NULL,
            type TEXT,
            notes TEXT,
            FOREIGN KEY(profileId) REFERENCES profiles(id) ON DELETE SET NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE settings (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            narration INTEGER,
            fontScale REAL,
            aiSuggestions INTEGER,
            faceRecognitionConsent INTEGER,
            emergencyName TEXT,
            emergencyPhone TEXT
          )
        ''');
        // default settings row
        await db.insert('settings', AppSettings().toMap()..['id'] = 1);
      },
    );
  }

  // Settings
  Future<AppSettings> getSettings() async {
    final db = await database;
    final maps = await db.query('settings', where: 'id = 1');
    if (maps.isNotEmpty) {
      return AppSettings.fromMap(maps.first);
    }
    return AppSettings();
  }

  Future<void> updateSettings(AppSettings s) async {
    final db = await database;
    await db.update('settings', s.toMap(), where: 'id = 1');
  }

  // Profiles
  Future<int> insertProfile(Profile p) async {
    final db = await database;
    return db.insert('profiles', p.toMap());
  }

  Future<int> updateProfile(Profile p) async {
    final db = await database;
    return db.update('profiles', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  Future<int> deleteProfile(int id) async {
    final db = await database;
    return db.delete('profiles', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Profile>> getProfiles() async {
    final db = await database;
    final maps = await db.query('profiles', orderBy: 'name');
    return maps.map((e) => Profile.fromMap(e)).toList();
  }

  Future<Profile?> getProfile(int id) async {
    final db = await database;
    final maps = await db.query('profiles', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Profile.fromMap(maps.first);
  }

  // Events
  Future<int> insertEvent(EventItem e) async {
    final db = await database;
    return db.insert('events', e.toMap());
  }

  Future<int> updateEvent(EventItem e) async {
    final db = await database;
    return db.update('events', e.toMap(), where: 'id = ?', whereArgs: [e.id]);
  }

  Future<int> deleteEvent(int id) async {
    final db = await database;
    return db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<EventItem>> getEventsForDay(DateTime day) async {
    final db = await database;
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final maps = await db.query(
      'events',
      where: 'dateTime >= ? AND dateTime < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'dateTime',
    );
    return maps.map((e) => EventItem.fromMap(e)).toList();
  }

  Future<List<EventItem>> getUpcomingEvents({int limit = 10}) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final maps = await db.query(
      'events',
      where: 'dateTime >= ?',
      whereArgs: [now],
      orderBy: 'dateTime',
      limit: limit,
    );
    return maps.map((e) => EventItem.fromMap(e)).toList();
  }
}
