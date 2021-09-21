import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobiforce_flutter/data/models/resolution_model.dart';
import 'package:mobiforce_flutter/data/models/task_life_cycle_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/taskfield_model.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/data/models/tasksstatuses_model.dart';
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
  String taskFieldTable="taskfield";
  String resolutionTable="resolution";
  String taskStatusTable="taskstatus";
  String tasksStatusesTable="tasksstatuses";
  String taskLifeCycleTable="tasklifecycletable";
  String tasksFieldsTable="tasksfields";

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
        'CREATE TABLE IF NOT EXISTS  $taskStatusTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'dirty INTEGER, '
            'external_id INTEGER UNIQUE, '
            'usn INTEGER, '
            'color TEXT, '
            'name TEXT)');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS  $taskFieldTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'dirty INTEGER, '
            'external_id INTEGER UNIQUE, '
            'usn INTEGER, '
            'type INTEGER, '
            'name TEXT)');

    await db.execute(
        'CREATE TABLE IF NOT EXISTS  $tasksFieldsTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'dirty INTEGER, '
            'external_id INTEGER UNIQUE, '
            'usn INTEGER, '
            'task INTEGER, '
            'parent_id INTEGER, '
            'element_id INTEGER, '
            'task_field INTEGER, '
            'sort INTEGER'
            ')');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS  $taskLifeCycleTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'dirty INTEGER, '
            'external_id INTEGER UNIQUE, '
            'usn INTEGER, '
            'current_status INTEGER,  '
            'next_status INTEGER,  '
            'need_resolution INTEGER)');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS  $tasksTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'dirty INTEGER, '
            'external_id INTEGER UNIQUE, '
            'usn INTEGER, '
            'status INTEGER, '
            'client TEXT, '
            'address TEXT, '
            'name TEXT)');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS  $resolutionTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'dirty INTEGER, '
            'external_id INTEGER UNIQUE, '
            'client TEXT, '
            'address TEXT, '
            'name TEXT)');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $tasksStatusesTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'dirty INTEGER, '
            'external_id INTEGER UNIQUE, '
            'task_status INTEGER, '
            'created_time INTEGER, '
            'manual_time INTEGER, '
            'task INTEGER, '
            'lat TEXT, '
            'lon TEXT)');
  }
//CLEAR BASE
  Future<void> clear() async{
    Database db = await this.database;
    print("DROP");
    await db.execute('DROP TABLE IF EXISTS $tasksTable');
    await db.execute('DROP TABLE IF EXISTS $resolutionTable');
    await db.execute('DROP TABLE IF EXISTS $taskStatusTable');
    await db.execute('DROP TABLE IF EXISTS $tasksStatusesTable');
    await db.execute('DROP TABLE IF EXISTS $taskLifeCycleTable');
    await db.execute('DROP TABLE IF EXISTS $tasksFieldsTable');
    await db.execute('DROP TABLE IF EXISTS $taskFieldTable');
    _createDB(db, 1);
  }

//READ
  Future<TaskModel> getTask(int id) async {
    Database db = await this.database;
    final List<Map<String,dynamic>> tasksMapList = await db.query(tasksTable, orderBy: "id desc",limit: 1,where: 'id =?', whereArgs: [id]);
    final List<Map<String,dynamic>> taskStatusMapList = await db.query(taskStatusTable, orderBy: "id desc",limit: 1,where: 'id =?', whereArgs: [tasksMapList.first['status']]);
    final List<Map<String,dynamic>> tasksStatusesMapList = await db.rawQuery("SELECT t1.*, t2.name, t2.color FROM $tasksStatusesTable as t1 LEFT JOIN $taskStatusTable as t2 ON t1.task_status = t2.id WHERE t1.task = ? ORDER BY t1.id DESC",[id]);
    final List<Map<String,dynamic>> tasksFieldsMapList = await db.rawQuery("SELECT t1.*, "
      "t2.name as field_name, "
      "t2.type as field_type, "
      "t2.id as field_id, "
      "t2.usn as field_usn, "
      "t2.external_id as field_external_id "
      "FROM $tasksFieldsTable as t1 LEFT JOIN $taskFieldTable as t2 ON t1.task_field = t2.id WHERE t1.task = ? ORDER BY t1.id DESC",[id]);
    return TaskModel.fromMap(tasksMapList.first,taskStatusMapList.first,tasksStatusesMapList,tasksFieldsMapList);
  }
  Future<List<TaskStatusModel>> getNextStatuses(int ?id) async {
    Database db = await this.database;
    final List<TaskStatusModel> taskStatusesList = [];
    final List<Map<String,dynamic>> tasksMapList = await db.rawQuery("SELECT t2.* FROM $taskLifeCycleTable as t1 LEFT JOIN $taskStatusTable as t2 ON t1.next_status = t2.id WHERE t1.current_status = ?",[id]);
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
      List<Map<String,dynamic>> taskStatusMapList = await db.query(taskStatusTable, orderBy: "id desc",limit: 1,where: 'id =?', whereArgs: [taskMap['status']]);
      //taskMap["status"]=null;
      tasksList.add(TaskModel.fromMap(taskMap,taskStatusMapList.first,[],[]));
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
  Future<TasksStatusesModel> insertTasksStatuses(TasksStatusesModel tasksStatuses) async{
    Database db = await this.database;
    int id=0;
    try{
      print('${tasksStatuses.toMap().toString()}');
      id=await db.insert(tasksStatusesTable, tasksStatuses.toMap());
    }
    catch(e){
      //await db(tasksTable, task.toMap());
    }
    tasksStatuses.id=id;
    return tasksStatuses;
  }
  Future<int> addStatusToTask(TasksStatusesModel ts) async {
    Database db = await this.database;
    int id=0;
    try{
      //print('${tasksStatuses.toMap().toString()}');
      id=await db.insert(tasksStatusesTable, ts.toMap());
    }
    catch(e){
      //await db(tasksTable, task.toMap());
    }
    ts.id=id;
    return id;
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

    int taskId = await getTaskIdByServerId(task.serverId);
    if(taskId!=0)
      await db.update(tasksTable, task.toMap(), where: 'external_id =?', whereArgs: [taskId]);
    //task.id=taskId;
    return taskId;
  }


  Future<TasksStatusesModel> updateTasksStatusesByServerId(TasksStatusesModel task) async{
    Database db = await this.database;

    int tasksStatusesId = await getTasksStatusesIdByServerId(task.serverId);
    if(tasksStatusesId!=0)
      await db.update(tasksStatusesTable, task.toMap(), where: 'external_id =?', whereArgs: [tasksStatusesId]);
    task.id=tasksStatusesId;
    return task;


  }
//DELETE
  Future<int> deleteTask(int id) async{
    Database db = await this.database;
    return await db.delete(tasksTable, where: 'id =?', whereArgs: [id]);
  }

  Future<TaskStatusModel?> getTaskStatusByServerId(int serverId) async {
    Database db = await this.database;
    final List<Map<String,dynamic>> tasksMapList = await db.query(taskStatusTable, orderBy: "id desc",limit: 1,where: 'external_id =?', whereArgs: [serverId]);
    return tasksMapList.isNotEmpty?TaskStatusModel.fromMap(tasksMapList.first):null;
  }

  Future<int> getTaskIdByServerId(int serverId) async {
    Database db = await this.database;
    final List<Map<String,dynamic>> tasksMapList = await db.query(tasksTable, orderBy: "id desc",limit: 1,where: 'external_id =?', whereArgs: [serverId]);
    return tasksMapList.first["id"]??0;//tasksMapList.isNotEmpty?TaskModel.fromMap(tasksMapList.first):null;
  }
  Future<int> getTaskStatusIdByServerId(int serverId) async {
    Database db = await this.database;
    print("TaskStatus serverId = $serverId");

    final List<Map<String,dynamic>> tasksStatusMapList = await db.query(taskStatusTable, orderBy: "id desc",limit: 1,where: 'external_id =?', whereArgs: [serverId]);
    return tasksStatusMapList.first["id"]??0;//tasksMapList.isNotEmpty?TaskModel.fromMap(tasksMapList.first):null;
  }
  Future<int> getTasksStatusesIdByServerId(int? serverId) async {
    Database db = await this.database;
    print("serverId = $serverId");
    final List<Map<String,dynamic>> tasksMapList = await db.query(tasksStatusesTable, orderBy: "id desc",limit: 1,where: 'external_id =?', whereArgs: [serverId]);
    return tasksMapList.first["id"]??0;//tasksMapList.isNotEmpty?TaskModel.fromMap(tasksMapList.first):null;
  }

  Future<TaskStatusModel?> getTaskStatus(int id) async {
    Database db = await this.database;
    final List<Map<String,dynamic>> tasksMapList = await db.query(taskStatusTable, orderBy: "id desc",limit: 1,where: 'id =?', whereArgs: [id]);
    return tasksMapList.isNotEmpty?TaskStatusModel.fromMap(tasksMapList.first):null;
  }


  Future<TaskStatusModel> insertTaskStatus(TaskStatusModel taskStatus) async {
    Database db = await this.database;
    int id=0;
    try{
      id=await db.insert(taskStatusTable, taskStatus.toMap());
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
      await db.update(taskStatusTable, taskStatus.toMap(), where: 'id =?', whereArgs: [ts?.id]);
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

  Future<TaskFieldModel> insertTaskField(TaskFieldModel taskFieldModel) async {
    Database db = await this.database;
    int id=0;
    try{
      id=await db.insert(taskFieldTable, taskFieldModel.toMap());
    }
    catch(e){
      //await db(tasksTable, task.toMap());
    }
    taskFieldModel.id=id;
    return taskFieldModel;

  }

  Future<int> updateTaskFieldByServerId(TaskFieldModel taskFieldModel) async{
    Database db = await this.database;

    int taskId = await getTaskFieldIdByServerId(taskFieldModel.serverId);
    if(taskId!=0)
      await db.update(taskFieldTable, taskFieldModel.toMap(), where: 'external_id =?', whereArgs: [taskId]);
    //task.id=taskId;
    return taskId;
  }
  Future<int> getTaskFieldIdByServerId(int serverId) async {
    Database db = await this.database;
    final List<Map<String,dynamic>> tasksMapList = await db.query(taskFieldTable, orderBy: "id desc",limit: 1,where: 'external_id =?', whereArgs: [serverId]);
    return tasksMapList.first["id"]??0;//tasksMapList.isNotEmpty?TaskModel.fromMap(tasksMapList.first):null;
  }


  Future<TasksFieldsModel> insertTasksFields(TasksFieldsModel taskFieldModel) async {
    Database db = await this.database;
    int id=0;
    try{
      id=await db.insert(tasksFieldsTable, taskFieldModel.toMap());
    }
    catch(e){
      //await db(tasksTable, task.toMap());
    }
    taskFieldModel.id=id;
    return taskFieldModel;

  }

  Future<int> updateTasksFieldsByServerId(TasksFieldsModel taskFieldModel) async{
    Database db = await this.database;

    int taskId = await getTasksFieldIdByServerId(taskFieldModel.serverId);
    if(taskId!=0)
      await db.update(tasksFieldsTable, taskFieldModel.toMap(), where: 'external_id =?', whereArgs: [taskId]);
    //task.id=taskId;
    return taskId;
  }
  Future<int> getTasksFieldIdByServerId(int serverId) async {
    Database db = await this.database;
    final List<Map<String,dynamic>> tasksMapList = await db.query(tasksFieldsTable, orderBy: "id desc",limit: 1,where: 'external_id =?', whereArgs: [serverId]);
    return tasksMapList.first["id"]??0;//tasksMapList.isNotEmpty?TaskModel.fromMap(tasksMapList.first):null;
  }

}