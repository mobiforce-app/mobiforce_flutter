import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobiforce_flutter/data/models/resolution_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  //DBProvider._();
  final int limit=30;
  final String dbName="mf.db";
  final int dbVersion=1;
  static final DBProvider _instance = new DBProvider.internal();

  factory DBProvider() => _instance;
  //static final DBProvider db = DBProvider._();

  static Database? _database;
  String tasksTable="task";
  String resolutionTable="resolution";

  DBProvider.internal();

//  static Database _db;

  Future<Database> _initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + dbName;
    return await openDatabase(path, version: dbVersion, onCreate: _createDB);
  }



  Future<Database> get database async {
    return _database ??= await _initDB();
  }
/*    if (_database != null)
      return _database;
    _database = await _initDB();
    return _database;
  }
*/
  //CREATE
  void _createDB(Database db, int version) async {

    await db.execute(
        'CREATE TABLE $tasksTable (id INTEGER PRIMARY KEY AUTOINCREMENT, external_id INTEGER UNIQUE, usn INTEGER, client TEXT, address TEXT, name TEXT)');
  }
//CLEAR BASE
  Future<void> clear() async{
    Database db = await this.database;
    print("DROP");
    await db.execute('DROP TABLE IF EXISTS $tasksTable');
    await db.execute('DROP TABLE IF EXISTS $resolutionTable');
    await db.execute(
        'CREATE TABLE $tasksTable (id INTEGER PRIMARY KEY AUTOINCREMENT, external_id INTEGER UNIQUE, usn INTEGER, client TEXT, address TEXT, name TEXT)');
    await db.execute(
        'CREATE TABLE $resolutionTable (id INTEGER PRIMARY KEY AUTOINCREMENT, external_id INTEGER UNIQUE, client TEXT, address TEXT, name TEXT)');
  }

//READ
  Future<List<TaskModel>> getTasks(int page) async {
    Database db = await this.database;
    print("limit $limit, offset $page");
    final List<Map<String,dynamic>> tasksMapList = await db.query(tasksTable,limit: limit,offset: limit*page);
    final List<TaskModel> tasksList = [];
    tasksMapList.forEach((taskMap){
      tasksList.add(TaskModel.fromMap(taskMap));
    });
    return tasksList;
  }
//INSERT
  Future<TaskModel> insertTask(TaskModel task) async{
    Database db = await this.database;
    int id=0;
    try{
      id=await db.insert(tasksTable, task.toMap());
    }
    catch(e){
      //await db(tasksTable, task.toMap());
    }
    task.id=id;
    return task;
  }
  Future<ResolutionModel> insertResolution(ResolutionModel resolution) async{
    Database db = await this.database;
    int id=0;
    try{
      id=await db.insert(resolutionTable, resolution.toMap());
    }
    catch(e){
      //await db(tasksTable, task.toMap());
    }
    resolution.id=id;
    return resolution;
  }
//UPDATE
  Future<int> updateTask(TaskModel task) async{
    Database db = await this.database;
    return await db.update(tasksTable, task.toMap(), where: 'id =?', whereArgs: [task.id]);

  }
//DELETE
  Future<int> deleteTask(int id) async{
    Database db = await this.database;
    return await db.delete(tasksTable, where: 'id =?', whereArgs: [id]);
  }
}