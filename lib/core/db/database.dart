import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobiforce_flutter/data/models/resolution_model.dart';
import 'package:mobiforce_flutter/data/models/task_life_cycle_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/taskstatus_model.dart';
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
  String taskStatusesTable="taskstatus";
  String taskLifeCycleTable="tasklifecycletable";

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
        'CREATE TABLE $taskStatusesTable (id INTEGER PRIMARY KEY AUTOINCREMENT, external_id INTEGER UNIQUE, usn INTEGER, color TEXT, name TEXT)');
    await db.execute(
        'CREATE TABLE $taskLifeCycleTable (id INTEGER PRIMARY KEY AUTOINCREMENT, external_id INTEGER UNIQUE, usn INTEGER, current_status INTEGER,  next_status INTEGER,  need_resolution INTEGER)');
    await db.execute(
        'CREATE TABLE $tasksTable (id INTEGER PRIMARY KEY AUTOINCREMENT, external_id INTEGER UNIQUE, usn INTEGER, status INTEGER, client TEXT, address TEXT, name TEXT)');
    await db.execute(
        'CREATE TABLE $resolutionTable (id INTEGER PRIMARY KEY AUTOINCREMENT, external_id INTEGER UNIQUE, client TEXT, address TEXT, name TEXT)');
  }
//CLEAR BASE
  Future<void> clear() async{
    Database db = await this.database;
    print("DROP");
    await db.execute('DROP TABLE IF EXISTS $tasksTable');
    await db.execute('DROP TABLE IF EXISTS $resolutionTable');
    await db.execute('DROP TABLE IF EXISTS $taskStatusesTable');
    await db.execute('DROP TABLE IF EXISTS $taskLifeCycleTable');
    _createDB(db, 1);
  }

//READ
  Future<TaskModel> getTask(int id) async {
    Database db = await this.database;
    final List<Map<String,dynamic>> tasksMapList = await db.query(tasksTable, orderBy: "id desc",limit: 1,where: 'id =?', whereArgs: [id]);
    final List<Map<String,dynamic>> taskStatusMapList = await db.query(taskStatusesTable, orderBy: "id desc",limit: 1,where: 'id =?', whereArgs: [tasksMapList.first['status']]);
    return TaskModel.fromMap(tasksMapList.first,taskStatusMapList.first);
  }
  Future<List<TaskStatusModel>> getNextStatuses(int ?id) async {
    Database db = await this.database;
    final List<TaskStatusModel> taskStatusesList = [];
    final List<Map<String,dynamic>> tasksMapList = await db.rawQuery("SELECT t2.* FROM $taskLifeCycleTable as t1 LEFT JOIN $taskStatusesTable as t2 ON t1.next_status = t2.id WHERE t1.current_status = ?",[id]);
    //final List<Map<String,dynamic>> tasksMapList = await db.query(tasksTable, orderBy: "id desc",limit: 1,where: 'id =?', whereArgs: [id]);
    tasksMapList.forEach((element) {
      print("element = ${element.toString()}");
      taskStatusesList.add(TaskStatusModel.fromMap(element));
    });
    //final List<Map<String,dynamic>> taskStatusMapList = await db.query(taskStatusesTable, orderBy: "id desc",limit: 1,where: 'id =?', whereArgs: [tasksMapList.first['status']]);
    return taskStatusesList;//TaskModel.fromMap(tasksMapList.first,taskStatusMapList.first);
  }
  Future<List<TaskModel>> getTasks(int page) async {
    Database db = await this.database;
    print("limit $limit, offset $page");
    final List<Map<String,dynamic>> tasksMapList = await db.query(tasksTable, orderBy: "id desc",limit: limit,offset: limit*page);
    final List<TaskModel> tasksList = [];
    //await Future.forEach(tasksMapList,(taskMap) async {
      //int statusId = taskMap['status'];
      //await getTaskStatus(?taskMap["status"]);
      //tasksList.add(TaskModel.fromMap(taskMap));
    //});
    for (Map<String,dynamic> taskMap in tasksMapList)
    {
      //int statusId = taskMap['status'];
      //TaskStatusModel? ts = await getTaskStatus(taskMap["status"]);
      List<Map<String,dynamic>> taskStatusMapList = await db.query(taskStatusesTable, orderBy: "id desc",limit: 1,where: 'id =?', whereArgs: [taskMap['status']]);
      //taskMap["status"]=null;
      tasksList.add(TaskModel.fromMap(taskMap,taskStatusMapList.first));
    }
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
  Future<int> updateTaskByServerId(TaskModel task) async{
    Database db = await this.database;
    return await db.update(tasksTable, task.toMap(), where: 'external_id =?', whereArgs: [task.serverId]);

  }
//DELETE
  Future<int> deleteTask(int id) async{
    Database db = await this.database;
    return await db.delete(tasksTable, where: 'id =?', whereArgs: [id]);
  }

  Future<TaskStatusModel?> getTaskStatusByServerId(int serverId) async {
    Database db = await this.database;
    final List<Map<String,dynamic>> tasksMapList = await db.query(taskStatusesTable, orderBy: "id desc",limit: 1,where: 'external_id =?', whereArgs: [serverId]);
    return tasksMapList.isNotEmpty?TaskStatusModel.fromMap(tasksMapList.first):null;
  }

  Future<TaskStatusModel?> getTaskStatus(int id) async {
    Database db = await this.database;
    final List<Map<String,dynamic>> tasksMapList = await db.query(taskStatusesTable, orderBy: "id desc",limit: 1,where: 'id =?', whereArgs: [id]);
    return tasksMapList.isNotEmpty?TaskStatusModel.fromMap(tasksMapList.first):null;
  }


  Future<TaskStatusModel> insertTaskStatus(TaskStatusModel taskStatus) async {
    Database db = await this.database;
    int id=0;
    try{
      id=await db.insert(taskStatusesTable, taskStatus.toMap());
    }
    catch(e){
      print("$e");
      //await db(tasksTable, task.toMap());
    }
    taskStatus.id=id;
    return taskStatus;
  }

  //updateStatusByServerId(TaskStatusModel taskStatusModel) async {}
  Future<int?> updateTaskStatusByServerId(TaskStatusModel taskStatus) async{
    Database db = await this.database;
    TaskStatusModel? ts = await getTaskStatusByServerId(taskStatus.serverId);
    if(ts?.serverId!=null)
      await db.update(taskStatusesTable, taskStatus.toMap(), where: 'id =?', whereArgs: [ts?.id]);
    return ts?.id;
  }

  Future<TaskLifeCycleModel> insertTaskLifeCycle(TaskLifeCycleModel taskLifeCycle) async {
    Database db = await this.database;
    int id=0;
    try{
      id=await db.insert(taskLifeCycleTable, taskLifeCycle.toMap());
    }
    catch(e){
      //await db(tasksTable, task.toMap());
    }
    taskLifeCycle.id=id;
    return taskLifeCycle;
  }
  Future<int> updateTaskLifeCycleByServerId(TaskLifeCycleModel taskLifeCycle) async{
    Database db = await this.database;
    return await db.update(taskLifeCycleTable, taskLifeCycle.toMap(), where: 'external_id =?', whereArgs: [taskLifeCycle.serverId]);

  }

}