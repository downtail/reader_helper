import 'dart:io';

import 'package:path/path.dart';
import 'package:reader_helper/entity/db/collect_entity.dart';
import 'package:reader_helper/entity/db/record_entity.dart';
import 'package:reader_helper/util/extension_list.dart';
import 'package:sqflite/sqflite.dart';

/// @author yi1993
/// @created at 2022/5/25
/// @description:
class DbManager {
  static final DbManager _dbManager = DbManager._();
  static const String _dbName = 'helper.db';
  late final Database _database;

  factory DbManager() => _dbManager;

  DbManager._();

  ///onCreate，onUpgrade，onDowngrade只会在版本变化时调用,并且在设置version之前
  Future<void> init() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, _dbName);
    // Make sure the directory exists
    try {
      await Directory(databasesPath).create(recursive: true);
      _database = await openDatabase(
        path,
        version: 1,
        onConfigure: (db) {},
        onCreate: (db, version) async {
          if (version == 1) {
            await db.execute('''
            create table $tableCollect (
            id integer primary key autoincrement,
            book text not null,
            date integer not null,
            data text not null,
            sort integer not null)
            ''');
            await db.execute('''
            create table $tableRecord (
            id integer primary key autoincrement,
            book text not null,
            position integer not null,
            alignment real not null)
            ''');
          }
        },
        onUpgrade: (db, oldVersion, newVersion) async {

        },
        onDowngrade: (db, oldVersion, newVersion) async {},
        onOpen: (db) async {},
      );
    } catch (_) {}
  }

  Future<RecordEntity> insertRecord({
    required RecordEntity item,
  }) async {
    item.id = await _database.insert(tableRecord, item.toMap());
    return item;
  }

  Future<RecordEntity?> isRecord({
    required String book,
  }) async {
    List<Map> maps = await _database.query(
      tableRecord,
      columns: [
        'id',
        'book',
        'position',
        'alignment',
      ],
      where: 'book = ?',
      whereArgs: [
        book,
      ],
    );
    if (maps.isNotEmptyOrNull) {
      return RecordEntity.fromMap(maps.first);
    }
    return RecordEntity(
      book: book,
      position: 0,
      alignment: 0,
    );
  }

  Future<int> modifyLocation({
    required RecordEntity item,
  }) async {
    return await _database.update(
      tableRecord,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [
        item.id,
      ],
    );
  }

  Future<CollectEntity> insertCollect({
    required CollectEntity item,
  }) async {
    item.id = await _database.insert(tableCollect, item.toMap());
    return item;
  }

  Future<int> deleteCollect({
    required String book,
  }) async {
    return await _database.delete(
      tableCollect,
      where: 'book = ?',
      whereArgs: [
        book,
      ],
    );
  }

  Future<CollectEntity?> isCollect({
    required String book,
  }) async {
    List<Map> maps = await _database.query(
      tableCollect,
      columns: [
        'id',
        'book',
        'date',
        'data',
        'sort',
      ],
      where: 'book = ?',
      whereArgs: [
        book,
      ],
    );
    if (maps.isNotEmptyOrNull) {
      return CollectEntity.fromMap(maps.first);
    }
    return null;
  }

  Future<int> modifyOriginal({
    required CollectEntity item,
  }) async {
    return await _database.update(
      tableCollect,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [
        item.id,
      ],
    );
  }

  Future<List<CollectEntity>?> getCollect() async {
    List<Map> maps = await _database.query(
      tableCollect,
      columns: [
        'id',
        'book',
        'date',
        'data',
        'sort',
      ],
      orderBy: 'sort desc',
    );
    if (maps.isNotEmptyOrNull) {
      return maps.map((e) => CollectEntity.fromMap(e)).toList();
    }
    return null;
  }
}
