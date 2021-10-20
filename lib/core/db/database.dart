import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobiforce_flutter/data/models/contractor_model.dart';
import 'package:mobiforce_flutter/data/models/employee_model.dart';
import 'package:mobiforce_flutter/data/models/file_model.dart';
import 'package:mobiforce_flutter/data/models/person_model.dart';
import 'package:mobiforce_flutter/data/models/phone_model.dart';
import 'package:mobiforce_flutter/data/models/resolution_group_model.dart';
import 'package:mobiforce_flutter/data/models/resolution_model.dart';
import 'package:mobiforce_flutter/data/models/selection_value_model.dart';
import 'package:mobiforce_flutter/data/models/task_comment_model.dart';
import 'package:mobiforce_flutter/data/models/task_life_cycle_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/taskfield_model.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/data/models/tasksstatuses_model.dart';
import 'package:mobiforce_flutter/data/models/taskstatus_model.dart';
import 'package:mobiforce_flutter/data/models/template_model.dart';
import 'package:mobiforce_flutter/domain/entity/taskfield_entity.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  //DBProvider._();
  final int limitToSend=30;
  final int limit=30;
  final String dbName="mf.db";
  final int dbVersion=1;
  static final DBProvider _instance = new DBProvider.internal();

  factory DBProvider() => _instance;
  //static final DBProvider db = DBProvider._();

  static Database? _database;
  String tasksTable="task";
  String fileTable="file";
  String taskFieldTable="taskfield";
  String resolutionTable="resolution";
  String resolutionGroupTable="resolutiongroup";
  String resolutionGroup2ResolutionRelationTable="resolutiongroup2resolutionrelation";

  String taskSelectionValuesTable="taskselectionvalue";
  String taskSelectionValuesRelationTable="taskselectionvaluerelation";
  String taskStatusTable="taskstatus";
  String taskCommentTable="taskcomment";
  String tasksStatusesTable="tasksstatuses";
  String taskLifeCycleTable="tasklifecycletable";
  String tasksFieldsTable="tasksfields";
  String tasksFieldsTabTable="tasksfieldstab";
  String taskValuesTable="taskvaluestable";
  String employeeTable="employeetable";
  String employee2TaskRelationTable="employee2taskrelationtable";
  String tasksPersonTable="taskpersontable";
  String tasksPhoneTable="taskphonetable";
  String tasksTemplateTable="tasktamplatetable";
  String contractorTable="contractortable";
  String usnCountersTable="usncounterstable";
  String usnCountersFileTable="usnfiletable";


  DBProvider.internal();

//  static Database _db;

  Future<Database> _initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + dbName;
    return await openDatabase(path, version: dbVersion, onCreate: await _createDB);
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
  Future<void> _createDB(Database db, int version) async {

    await db.execute(
        'CREATE TABLE IF NOT EXISTS  $taskStatusTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'dirty INTEGER, '
            'external_id INTEGER UNIQUE, '
            'system_status_id INTEGER, '
            'usn INTEGER, '
            'color TEXT, '
            'name TEXT)');

    await db.execute(
        'CREATE TABLE IF NOT EXISTS  $fileTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'dirty INTEGER, '
            'external_id INTEGER UNIQUE, '
            'type INTEGER, '
            'link_object INTEGER, '
            'link_object_type INTEGER, '
            'downloaded INTEGER, '
            'deleted INTEGER, '
            'usn INTEGER, '
            'name TEXT, '
            'description TEXT)');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS  $taskCommentTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'dirty INTEGER, '
            'external_id INTEGER UNIQUE, '
            'task INTEGER, '
            'author INTEGER, '
            'deleted INTEGER, '
            'usn INTEGER, '
            'file INTEGER, '
            'created_at INTEGER,'
            'message TEXT)');

    await db.execute(
        'CREATE TABLE IF NOT EXISTS  $usnCountersTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'object_type TEXT, '
            'usn_counter INTEGER'
            ')');
    await db.insert(usnCountersTable, {'object_type':'task_option','usn_counter':0});
    await db.execute(
        'CREATE TABLE IF NOT EXISTS  $usnCountersFileTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'object_type TEXT, '
            'usn_counter INTEGER'
            ')');
    await db.insert(usnCountersFileTable, {'object_type':'task_option','usn_counter':0});


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
            'tasks_fields_tab INTEGER, '
            'sort INTEGER'
            ')');
    print('CREATE TABLE IF NOT EXISTS  $tasksFieldsTable ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'dirty INTEGER, '
        'external_id INTEGER UNIQUE, '
        'usn INTEGER, '
        'task INTEGER, '
        'parent_id INTEGER, '
        'element_id INTEGER, '
        'task_field INTEGER, '
        'tasks_fields_tab INTEGER, '
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
            'contractor int, '
            'deleted int, '
            'author int, '
            'resolution INTEGER, '
            'template int, '
            'address TEXT, '
            'name TEXT,'
            'address_floor TEXT,'
            'address_info TEXT,'
            'address_porch TEXT,'
            'address_room TEXT,'
            'lat TEXT,'
            'lon TEXT,'
            'external_link TEXT,'
            'external_link_name TEXT,'
            'created_at INTEGER,'
            'planned_visit_time INTEGER,'
            'planned_end_visit_time INTEGER'
            ')');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS  $resolutionTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'dirty INTEGER, '
            'external_id INTEGER UNIQUE, '
            'name TEXT)');

    await db.execute(
        'CREATE TABLE IF NOT EXISTS  $resolutionGroupTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'dirty INTEGER, '
            'external_id INTEGER UNIQUE, '
            'name TEXT)');

    await db.execute(
        'CREATE TABLE IF NOT EXISTS  $resolutionGroup2ResolutionRelationTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'resolution INTEGER,'
            'resolution_group INTEGER'
            ')');

    await db.execute(
        'CREATE TABLE IF NOT EXISTS  $tasksFieldsTabTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'dirty INTEGER, '
            'external_id INTEGER UNIQUE, '
            'main_page INTEGER,'
            'name TEXT)');
    await db.insert(tasksFieldsTabTable, {'external_id':1,'main_page':1,'name':'Основное'});
    await db.insert(tasksFieldsTabTable, {'external_id':2,'name':'Отчет'});

    await db.execute(
        'CREATE TABLE IF NOT EXISTS  $taskSelectionValuesTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'dirty INTEGER, '
            'external_id INTEGER UNIQUE, '
            'sorting INTEGER, '
            'deleted INTEGER, '
            'task_field INTEGER, '
            'name TEXT)');

    await db.execute(
        'CREATE TABLE IF NOT EXISTS  $taskSelectionValuesRelationTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'tasks_fields INTEGER, '
            'tasks_selection_values INTEGER '
            ')');

    await db.execute(
        'CREATE TABLE IF NOT EXISTS  $taskValuesTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'tasks_fields INTEGER, '
            'value TEXT '
            ')');

    await db.execute(
        'CREATE TABLE IF NOT EXISTS $tasksStatusesTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'usn INTEGER, '
            'dirty INTEGER, '
            'external_id INTEGER UNIQUE, '
            'task_status INTEGER, '
            'created_time INTEGER, '
            'manual_time INTEGER, '
            'task INTEGER, '
            'lat TEXT, '
            'lon TEXT)');

    await db.execute(
        'CREATE TABLE IF NOT EXISTS $contractorTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'dirty INTEGER, '
            'usn INTEGER, '
            'external_id INTEGER UNIQUE, '
            'parent INTEGER, '
            'name TEXT, '
            'address TEXT, '
            'address_floor TEXT, '
            'address_info TEXT, '
            'address_porch TEXT, '
            'address_room TEXT, '
            'lat TEXT, '
            'lon TEXT)');

    await db.execute(
        'CREATE TABLE IF NOT EXISTS $employeeTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'dirty INTEGER, '
            'usn INTEGER, '
            'external_id INTEGER UNIQUE, '
            'name TEXT, '
            'mobile_auth INTEGER, '
            'web_auth INTEGER '
            ')');

    await db.execute(
        'CREATE TABLE IF NOT EXISTS $employee2TaskRelationTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'task INTEGER, '
            'employee INTEGER '
            ')');

    await db.execute(
        'CREATE TABLE IF NOT EXISTS $tasksPersonTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'dirty INTEGER, '
            'usn INTEGER, '
            'contractor INTEGER, '
            'task INTEGER, '
            'external_id INTEGER UNIQUE, '
            'name TEXT'
            ')');

    await db.execute(
        'CREATE TABLE IF NOT EXISTS $tasksPhoneTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'dirty INTEGER, '
            'usn INTEGER, '
            'person INTEGER, '
            'task INTEGER, '
            'external_id INTEGER UNIQUE, '
            'name TEXT'
            ')');

    await db.execute(
        'CREATE TABLE IF NOT EXISTS $tasksTemplateTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'dirty INTEGER, '
            'usn INTEGER, '
            'external_id INTEGER UNIQUE, '
            'name TEXT'
            ')');

  }
//CLEAR BASE
  Future<void> clear() async{
    Database db = await this.database;
    print("DROP");
    await db.execute('DROP TABLE IF EXISTS $fileTable');
    await db.execute('DROP TABLE IF EXISTS $tasksTable');
    await db.execute('DROP TABLE IF EXISTS $taskCommentTable');
    await db.execute('DROP TABLE IF EXISTS $resolutionTable');
    await db.execute('DROP TABLE IF EXISTS $resolutionGroup2ResolutionRelationTable');
    await db.execute('DROP TABLE IF EXISTS $resolutionGroupTable');
    await db.execute('DROP TABLE IF EXISTS $taskSelectionValuesTable');
    await db.execute('DROP TABLE IF EXISTS $taskSelectionValuesRelationTable');
    await db.execute('DROP TABLE IF EXISTS $taskStatusTable');
    await db.execute('DROP TABLE IF EXISTS $tasksStatusesTable');
    await db.execute('DROP TABLE IF EXISTS $taskLifeCycleTable');
    await db.execute('DROP TABLE IF EXISTS $tasksFieldsTable');
    await db.execute('DROP TABLE IF EXISTS $tasksFieldsTabTable');
    await db.execute('DROP TABLE IF EXISTS $taskFieldTable');
    await db.execute('DROP TABLE IF EXISTS $taskValuesTable');
    await db.execute('DROP TABLE IF EXISTS $employeeTable');
    await db.execute('DROP TABLE IF EXISTS $tasksPersonTable');
    await db.execute('DROP TABLE IF EXISTS $tasksPhoneTable');
    await db.execute('DROP TABLE IF EXISTS $tasksTemplateTable');
    await db.execute('DROP TABLE IF EXISTS $contractorTable');
    await db.execute('DROP TABLE IF EXISTS $employee2TaskRelationTable');
    await db.execute('DROP TABLE IF EXISTS $usnCountersTable');
    await db.execute('DROP TABLE IF EXISTS $usnCountersFileTable');
    await _createDB(db, 1);
  }
//READ
  Future<List<TasksFieldsModel>> readTasksFieldsUpdates(int localUSN) async{
   //return null;
    print("localUSN $localUSN");
    Database db = await this.database;
    final List<Map<String,dynamic>> tasksFieldsMapList = await db.rawQuery("SELECT t1.*, "
        "t1.task as task_id, "
        "t2.name as field_name, "
        "t2.type as field_type, "
        "t2.id as field_id, "
        "t2.usn as field_usn, "
        "t2.external_id as field_external_id, "
        "t4.id as task_selection_value_id, "
        "t4.name as task_selection_value_name, "
        "t4.external_id as task_selection_value_external_id, "
        "t5.value as value "
        "FROM $tasksFieldsTable as t1 "
        "LEFT JOIN $taskFieldTable as t2 ON t1.task_field = t2.id "
        "LEFT JOIN $taskSelectionValuesRelationTable as t3 ON t1.id = t3.tasks_fields "
        "LEFT JOIN $taskSelectionValuesTable as t4 ON t3.tasks_selection_values = t4.id "
        "LEFT JOIN $taskValuesTable as t5 ON t1.id = t5.tasks_fields "
        "WHERE t1.usn > ? ORDER BY t1.usn ASC LIMIT $limitToSend",[localUSN]);

    final List<Map<String,dynamic>> tasksFieldsSelectionValuesMapList = await db.rawQuery("SELECT "
        "t1.id, "
        "t1.external_id, "
        "t1.name, "
        "t2.name as value_name, "
        "t2.external_id as value_external_id, "
        "t2.sorting as value_sorting, "
        "t2.id as value_id "
        "FROM $taskFieldTable as t1 LEFT JOIN $taskSelectionValuesTable as t2 ON t1.id = t2.task_field ORDER BY t1.id DESC",[]);
    final Map<int, dynamic> tasksFieldsSelectionValuesMap = reMapTasksFieldsSelectionValues(tasksFieldsSelectionValuesMapList);
    List<TasksFieldsModel> tasksFieldsUpdates=[];
    await Future.forEach(tasksFieldsMapList,(Map<String,dynamic> field) async {
      final TasksFieldsModel tf = TasksFieldsModel.fromMap(field,tasksFieldsSelectionValuesMap);
      if(tf.taskField?.type.value==TaskFieldTypeEnum.picture||tf.taskField?.type.value==TaskFieldTypeEnum.signature){
        final List<Map<String,dynamic>> tasksFieldsFilesMapList = await db.rawQuery("SELECT  "
            "t1.id as field_id, "
            "t2.external_id as field_external_id, "
            "t3.id as id, "
            "t3.link_object as link_object,"
            "t3.usn as usn, "
            "t3.link_object_type as link_object_type,"
            "t3.name as name, "
            "t3.external_id as external_id, "
            "t3.description as description "
            "FROM $tasksFieldsTable as t1 "
            "LEFT JOIN $taskFieldTable as t2 ON t1.task_field = t2.id "
            "LEFT JOIN $fileTable as t3 ON t1.id = t3.link_object "
            "WHERE t1.id = ? and t3.link_object_type = ? AND t3.id IS NOT NULL ORDER BY t1.id DESC",[tf.id, 1]);
        print("image files: ${tf.id} ${tasksFieldsFilesMapList.toString()}");
        tf.fileValueList=tasksFieldsFilesMapList.map((files) => FileModel.fromMap(files)).toList();
      }


      tasksFieldsUpdates.add(tf);
    });
    return tasksFieldsUpdates;
  }

  Future<int> addPictureToTaskField({required int taskFieldId,required int pictureId}) async{
    Database db = await this.database;
    int id=0;
    try{
      //id=await db.update(fileTable, {"deleted":1});
      int usn = await getFileUSN();
      dynamic map={
        "usn": usn,
        "link_object":taskFieldId,
        "deleted":0,
        "link_object_type":1,
      };
      print("to base ${map.toString()}, id: $pictureId");
      await db.update(fileTable, map, where: 'id =?', whereArgs: [pictureId]);
      usn = await getUSN();
      await db.update(tasksFieldsTable, {"usn":usn}, where: 'id =?', whereArgs: [taskFieldId]);
      return pictureId;
    }
    catch(e){
      //await db(tasksTable, task.toMap());
      return 0;
    }
    //task.id=id;
    //return id;
  }

  Future<int?> addPictureToTaskComment({required int taskCommentId,required int? pictureId}) async{
    Database db = await this.database;
    int id=0;
    try{
      //id=await db.update(fileTable, {"deleted":1});
      int usn = await getFileUSN();
      dynamic map={
        "usn": usn,
        "link_object":taskCommentId,
        "deleted":0,
        "link_object_type":2,
      };
      print("to base ${map.toString()}, id: $pictureId");
      if(pictureId!=null) {
        await db.update(fileTable, map, where: 'id =?', whereArgs: [pictureId]);
        await db.update(fileTable, map, where: 'id =?', whereArgs: [pictureId]);
      }
      //usn = await getUSN();
      //await db.update(tasksFieldsTable, {"usn":usn}, where: 'id =?', whereArgs: [taskCommentId]);
      return pictureId;
    }
    catch(e){
      //await db(tasksTable, task.toMap());
      return 0;
    }
    //task.id=id;
    //return id;
  }

  Future<int> newFileRecord() async{
    Database db = await this.database;
    int id=0;
    try{
      id=await db.insert(fileTable, {"deleted":1});
    }
    catch(e){
      //await db(tasksTable, task.toMap());
    }
    //task.id=id;
    return id;
  }

  Future<List<TasksStatusesModel>> readTaskStatusUpdates(int localUSN) async{
    Database db = await this.database;
    final List<Map<String,dynamic>> tasksStatusesMapList = await db.rawQuery(""
        "SELECT t1.*, "
        //"t4.external_id as resolution_external_id,t4.id as resolution_id,t4.name as resolution_name, "
        "t2.name as taskstatus_name, t2.color as taskstatus_color, t2.external_id as taskstatus_external_id, t2.id as taskstatus_id, t3.external_id as task_external_id, t3.id as task_id "
        "FROM $tasksStatusesTable as t1 "
        "LEFT JOIN $taskStatusTable as t2 "
        "ON t1.task_status = t2.id "
        "LEFT JOIN $tasksTable as t3 "
        "ON t1.task = t3.id "
        //"LEFT JOIN $resolutionTable as t4 "
        //"ON t1.resolution = t4.id "
        "WHERE t1.usn > ? ORDER BY t1.usn ASC LIMIT $limitToSend",[localUSN]);
    return tasksStatusesMapList.map((taskstatus) => TasksStatusesModel.fromMap(taskstatus)).toList();
  }
  Future<List<TaskCommentModel>> readTaskCommentsUpdates(int localUSN) async{
    Database db = await this.database;
    final List<Map<String,dynamic>> tasksCommentsMapList = await db.rawQuery(""
        "SELECT t1.*, t2.id as task_id, t2.external_id as task_external_id "
        //"t4.external_id as resolution_external_id,t4.id as resolution_id,t4.name as resolution_name, "
        //"t2.name as taskstatus_name, t2.color as taskstatus_color, t2.external_id as taskstatus_external_id, t2.id as taskstatus_id, t3.external_id as task_external_id, t3.id as task_id "
        "FROM $taskCommentTable as t1 "
        "LEFT JOIN $tasksTable as t2 "
        "ON t1.task = t2.id "
        //"LEFT JOIN $tasksTable as t3 "
        //"ON t1.task = t3.id "
        //"LEFT JOIN $resolutionTable as t4 "
        //"ON t1.resolution = t4.id "
        "WHERE t1.usn > ? ORDER BY t1.usn ASC LIMIT $limitToSend",[localUSN]);
    print("tasksCommentsMapList ${tasksCommentsMapList.toString()} $localUSN");
    return tasksCommentsMapList.map((taskcomment) => TaskCommentModel.fromMap(taskcomment)).toList();
  }
  Future<List<FileModel>> readFilesUpdates(int localFileUSN) async{
    Database db = await this.database;
    final List<Map<String,dynamic>> tasksFieldsFilesMapList = await db.rawQuery("SELECT  "
        //"t2.id as field_id, "
        //"t2.external_id as field_external_id, "
        "t1.id as id, "
        "t1.name as name, "
        "t1.usn as usn, "
        "t1.external_id as external_id, "
        "t1.link_object as link_object,"
        "t1.link_object_type as link_object_type,"
        "t1.description as description "
        "FROM $fileTable as t1 "
        //"LEFT JOIN $tasksFieldsTable as t2 ON t1.link_object = t2.id "
        //"LEFT JOIN $fileTable as t3 ON t1.id = t3.link_object "
        "WHERE t1.usn > ? ORDER BY t1.usn ASC",[localFileUSN]);

    print("image files localFileUSN> ${localFileUSN} ${tasksFieldsFilesMapList.toString()}");

    //tf.fileValueList=tasksFieldsFilesMapList.map((files) => FileModel.fromMap(files)).toList();
    return tasksFieldsFilesMapList.map((taskfile) => FileModel.fromMap(taskfile)).toList();
  }
  Map<int, dynamic> reMapTasksFieldsSelectionValues(List<Map<String, dynamic>> tasksFieldsSelectionValuesMap) {
    int fieldId=0;

    //List<TaskFieldModel> taskFieldList = [];
    Map<int, dynamic> taskFieldSelectionValuesMap = {};
    List<Map<String, dynamic>> taskFieldSelectionValues = [];
    tasksFieldsSelectionValuesMap.forEach((element) {
      if(element["id"]!=fieldId){
        //taskFieldMapList.add(taskFieldMap);
        taskFieldSelectionValuesMap[fieldId]=taskFieldSelectionValues;
        fieldId=element["id"];
        //taskFieldMap={"id":element["id"],"name":element["name"]};
        taskFieldSelectionValues=[];
      }
      if(element["value_id"]!=null){
        taskFieldSelectionValues.add({
          "id":element["value_id"],
          "sorting":element["value_sorting"],
          "external_id":element["value_external_id"],
          "name":element["value_name"]});
      }

    });
    if(fieldId!=0)
      taskFieldSelectionValuesMap[fieldId]=taskFieldSelectionValues;
    return taskFieldSelectionValuesMap;

  }
  Future<TaskModel> getTask(int id) async {
    Database db = await this.database;
    final List<Map<String,dynamic>> tasksMapList = await db.rawQuery(
        "SELECT "
            "t1.id,"
            "t1.dirty, "
            "t1.external_id,"
            "t1.usn, "
            "t1.status, "
            "t1.contractor, "
            "t1.deleted, "
            "t1.author, "
            "t1.template, "
            "t1.address, "
            "t1.name,"
            "t1.address_floor,"
            "t1.address_info,"
            "t1.address_porch,"
            "t1.address_room,"
            "t1.lat,"
            "t1.lon,"
            "t1.external_link,"
            "t1.created_at,"
            "t1.planned_visit_time,"
            "t1.planned_end_visit_time,"
            "t2.id as contractor_id,"
            "t2.usn as contractor_usn,"
            "t2.external_id as contractor_external_id,"
            "t2.name as contractor_name,"
            "t3.id as contractor_parent_id,"
            "t3.usn as contractor_parent_usn,"
            "t3.external_id as contractor_parent_external_id,"
            "t3.name as contractor_parent_name"
            " FROM $tasksTable as t1 "
            " LEFT JOIN $contractorTable as t2"
            " ON t1.contractor = t2.id "
            " LEFT JOIN $contractorTable as t3"
            " ON t2.parent = t3.id "
            " WHERE t1.id=? AND t1.deleted != 1",[id]);
//        orderBy: "id desc",limit: 1,where: 'id =? AND deleted != 1', whereArgs: [id]);

    final List<Map<String,dynamic>> taskPhoneMapList = await db.rawQuery(""
        "SELECT t1.id, t1.name, t2.name as person_name, t2.id as person_id "
        "FROM $tasksPhoneTable as t1 "
        "LEFT JOIN $tasksPersonTable as t2 ON t1.person = t2.id "
        "WHERE t1.task = ? ORDER BY t1.person ASC",[id]);

    final List<Map<String,dynamic>> taskStatusMapList = await db.query(taskStatusTable, orderBy: "id desc",limit: 1,where: 'id =?', whereArgs: [tasksMapList.first['status']]);
    final List<Map<String,dynamic>> tasksStatusesMapList = await db.rawQuery("SELECT t1.*, t2.name as taskstatus_name, t2.color as taskstatus_color,t2.external_id as taskstatus_external_id, t2.id as taskstatus_id, t1.task as task_id FROM $tasksStatusesTable as t1 LEFT JOIN $taskStatusTable as t2 ON t1.task_status = t2.id WHERE t1.task = ? ORDER BY t1.id DESC",[id]);
    final List<Map<String,dynamic>> tasksFieldsSelectionValuesMapList = await db.rawQuery("SELECT "
          "t1.id, "
          "t1.external_id, "
          "t1.name, "
          "t2.name as value_name, "
          "t2.external_id as value_external_id, "
          "t2.sorting as value_sorting, "
          "t2.id as value_id "
        "FROM $taskFieldTable as t1 LEFT JOIN $taskSelectionValuesTable as t2 ON t1.id = t2.task_field ORDER BY t1.id DESC",[]);
    final List<Map<String,dynamic>> tasksFieldsMapList = await db.rawQuery("SELECT t1.*, "
      "t1.task as task_id, "
      "t2.name as field_name, "
      "t2.type as field_type, "
      "t2.id as field_id, "
      "t2.usn as field_usn, "
      "t2.external_id as field_external_id, "
      "t4.id as task_selection_value_id, "
      "t4.name as task_selection_value_name, "
      "t4.external_id as task_selection_value_external_id, "
      "t5.value as value "
      "FROM $tasksFieldsTable as t1 "
      "LEFT JOIN $taskFieldTable as t2 ON t1.task_field = t2.id "
      "LEFT JOIN $taskSelectionValuesRelationTable as t3 ON t1.id = t3.tasks_fields "
      "LEFT JOIN $taskSelectionValuesTable as t4 ON t3.tasks_selection_values = t4.id "
      "LEFT JOIN $taskValuesTable as t5 ON t1.id = t5.tasks_fields "
        "WHERE t1.task = ? ORDER BY t1.id DESC",[id]);

    final List<Map<String,dynamic>> tasksFieldsFilesMapList = await db.rawQuery("SELECT  "
      //"t1.task as task_id, "
      //"t2.name as field_name, "
      //"t2.type as field_type, "
      "t1.id as field_id, "
      //"t2.usn as field_usn, "
      "t2.external_id as field_external_id, "
      //"t2.id as task_file_id, "
      //"t2.external id as task_file_id, "
      "t3.id as id, "
      "t3.name as name, "
      "t3.external_id as external_id, "
      "t3.link_object as link_object,"
      "t3.usn as usn, "
      "t3.link_object_type as link_object_type,"
      "t3.description as description "
      "FROM $tasksFieldsTable as t1 "
      "LEFT JOIN $taskFieldTable as t2 ON t1.task_field = t2.id "
      "LEFT JOIN $fileTable as t3 ON t1.id = t3.link_object "
      "WHERE t1.task = ? and deleted = 0 and t3.link_object_type = ? AND t3.id IS NOT NULL ORDER BY t1.id DESC",[id, 1]);
    print("tasksFieldsFilesMapList: ${tasksFieldsFilesMapList.toString()}");
    return TaskModel.fromMap(
        taskMap:tasksMapList.first,
        statusMap:taskStatusMapList.first,
        statusesMap: tasksStatusesMapList,
        tasksFieldsMap: tasksFieldsMapList,
        tasksFieldsSelectionValuesMap:reMapTasksFieldsSelectionValues(tasksFieldsSelectionValuesMapList),
        taskPhoneMap:taskPhoneMapList,
        tasksFieldsFilesMap:tasksFieldsFilesMapList,
    );
  }
  Future<List<TaskStatusModel>> getNextStatuses(int ?id) async {
    Database db = await this.database;
    final List<TaskStatusModel> taskStatusesList = [];
    final List<Map<String,dynamic>> tasksMapList = await db.rawQuery("SELECT t1.need_resolution, t2.* FROM $taskLifeCycleTable as t1 LEFT JOIN $taskStatusTable as t2 ON t1.next_status = t2.id WHERE t1.current_status = ?",[id]);
    await Future.forEach(tasksMapList, (Map<String,dynamic> element) async {
      print("need_resolution ${element.toString()}");
      List<Map<String,dynamic>> resolutionsMapList = [];
      if(element["need_resolution"]>0){
        resolutionsMapList = await db.rawQuery("SELECT t2.* FROM $resolutionGroup2ResolutionRelationTable as t1 "
            "LEFT JOIN $resolutionTable as t2 ON t1.resolution=t2.id WHERE t1.resolution_group = ?",[element["need_resolution"]]);

      }
      print("element = ${element.toString()}");
      taskStatusesList.add(TaskStatusModel.fromMap(map:element,mapResolutions: resolutionsMapList));
    });
    //final List<Map<String,dynamic>> tasksMapList = await db.query(tasksTable, orderBy: "id desc",limit: 1,where: 'id =?', whereArgs: [id]);
    //final List<Map<String,dynamic>> taskStatusMapList = await db.query(taskStatusesTable, orderBy: "id desc",limit: 1,where: 'id =?', whereArgs: [tasksMapList.first['status']]);
    return taskStatusesList;//TaskModel.fromMap(tasksMapList.first,taskStatusMapList.first);
  }
  Future<List<TaskCommentModel>> getCommentList({required int task,required int page}) async {
    Database db = await this.database;
    final List<Map<String,dynamic>> taskCommentMapList = await db.rawQuery("SELECT "
        "t1.id, "
        "t1.usn, "
        "t1.external_id, "
        "t1.created_at, "
        "t1.message, "
        "t1.file, "
        "t2.id as author_id, "
        "t2.name as author_name, "
        "t3.id as task_id, "
        "t3.external_id as task_external_id "
        "FROM $taskCommentTable as t1 "
        "LEFT JOIN $employeeTable as t2 "
        "ON t1.author=t2.id "
        "LEFT JOIN $tasksTable as t3 "
        "ON t1.task = t3.id "
        ""
        "WHERE t1.task=? ORDER BY t1.id DESC",[task]);
    return taskCommentMapList.map((map) => TaskCommentModel.fromMap(map)).toList();



//    task:TaskModel.fromMap(taskMap: {"external_id":map['task_external_id']??0,"id":map['task_id']}, statusMap: null),

  }
  Future<List<TaskModel>> getTasks(int page) async {
    Database db = await this.database;
    print("limit $limit, offset $page");
    //final List<Map<String,dynamic>> tasksMapList = await db.query(tasksTable, orderBy: "id desc",limit: limit,offset: limit*page, where: "deleted != 1");
    final List<Map<String,dynamic>> tasksMapList = await db.rawQuery(
        "SELECT t1.id,"
            "t1.dirty, "
            "t1.external_id,"
            "t1.usn, "
            "t1.status, "
            "t1.contractor, "
            "t1.deleted, "
            "t1.author, "
            "t1.template, "
            "t1.address, "
            "t1.name,"
            "t1.address_floor,"
            "t1.address_info,"
            "t1.address_porch,"
            "t1.address_room,"
            "t1.lat,"
            "t1.lon,"
            "t1.external_link,"
            "t1.created_at,"
            "t1.planned_visit_time,"
            "t1.planned_end_visit_time,"
            "t2.id as contractor_id,"
            "t2.usn as contractor_usn,"
            "t2.external_id as contractor_external_id,"
            "t2.name as contractor_name,"
            "t3.id as contractor_parent_id,"
            "t3.usn as contractor_parent_usn,"
            "t3.external_id as contractor_parent_external_id,"
            "t3.name as contractor_parent_name"
            " FROM $tasksTable as t1 "
            " LEFT JOIN $contractorTable as t2"
            " ON t1.contractor = t2.id "
            " LEFT JOIN $contractorTable as t3"
            " ON t2.parent = t3.id "
            " WHERE t1.deleted != 1 ORDER BY t1.id DESC LIMIT ? OFFSET ? ",[limit, limit*page]);

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
      if(taskMap['status']!=null){
        List<Map<String,dynamic>> taskStatusMapList = await db.query(taskStatusTable, orderBy: "id desc",limit: 1,where: 'id =?', whereArgs: [taskMap['status']]);
        tasksList.add(TaskModel.fromMap(taskMap: taskMap,statusMap: taskStatusMapList.first));
      }
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

  Future<bool> deleteAllTaskEmployees(int taskId) async{
    Database db = await this.database;
    try{
      await db.delete(employee2TaskRelationTable, where: 'task =?', whereArgs: [taskId]);
    }
    catch(e){
      //await db(tasksTable, task.toMap());
      return false;
    }
    return true;
  }
  Future<bool> deleteAllTaskStatuses(int taskId) async{
    print ("task Id: $taskId");
    Database db = await this.database;
    try{
      await db.delete(tasksStatusesTable, where: 'task =?', whereArgs: [taskId]);
    }
    catch(e){
      //await db(tasksTable, task.toMap());
      return false;
    }
    return true;
  }
  Future<bool> deleteAllTaskPhones(int taskId) async{
    Database db = await this.database;
    try{
      await db.delete(tasksPhoneTable, where: 'task =?', whereArgs: [taskId]);
    }
    catch(e){
      //await db(tasksTable, task.toMap());
      return false;
    }
    return true;
  }
  Future<bool> deleteAllPersonPhones(int personId) async{
    Database db = await this.database;
    try{
      await db.delete(tasksPhoneTable, where: 'person =?', whereArgs: [personId]);
    }
    catch(e){
      //await db(tasksTable, task.toMap());
      return false;
    }
    return true;
  }
  Future<bool> deleteAllTaskPersons(int taskId) async{
    Database db = await this.database;
    try{
      await db.delete(tasksPersonTable, where: 'task =?', whereArgs: [taskId]);
    }
    catch(e){
      //await db(tasksTable, task.toMap());
      return false;
    }
    return true;
  }
  Future<bool> addTaskEmployee(int taskId, int employeeId) async{
    Database db = await this.database;
    try{
      await db.insert(employee2TaskRelationTable, {
        "task": taskId,
        "employee": employeeId
      });
    }
    catch(e){
      //await db(tasksTable, task.toMap());
      return false;
    }
    return true;
  }

  Future<int> getUSN() async{
    Database db = await this.database;
    try{
      int usn = await db.insert(usnCountersTable,{"object_type":"task_option"});
      print("usnresult: ${usn}");
      return usn;
    }
    catch(e){
      return 0;
    }
  }
  Future<int> getFileUSN() async{
    Database db = await this.database;
    try{
      int usn = await db.insert(usnCountersFileTable,{"object_type":"task_file"});
      print("usnresult: ${usn}");
      return usn;
    }
    catch(e){
      return 0;
    }
  }

  Future<bool> updateTaskFieldSelectionValue({required int taskFieldId,int? taskFieldSelectionValue,required  bool update_usn}) async{
    Database db = await this.database;

    try{
      await db.delete(taskSelectionValuesRelationTable, where: 'tasks_fields =?', whereArgs: [taskFieldId]);
    }
    catch(e){
      //await db(tasksTable, task.toMap());
    }
    if(taskFieldSelectionValue!=null) {
      try {
        if(update_usn) {
          int usn = await getUSN();
          await db.update(tasksFieldsTable, {
            "usn": usn,
          }, where: 'id =?', whereArgs: [taskFieldId]);
        }
        await db.insert(taskSelectionValuesRelationTable, {
          "tasks_fields": taskFieldId,
          "tasks_selection_values": taskFieldSelectionValue
        });

      }
      catch (e) {
        return false;
      }
    }
    return true;
  }
  Future<bool> updateTaskFieldValue({required int taskFieldId,String? taskFieldValue,required  bool update_usn}) async{
    Database db = await this.database;
    try{
      await db.delete(taskValuesTable, where: 'tasks_fields =?', whereArgs: [taskFieldId]);
    }
    catch(e){
      //await db(tasksTable, task.toMap());
    }
    if(taskFieldValue!=null) {
      try {
        if(update_usn) {
          int usn = await getUSN();
          await db.update(tasksFieldsTable, {
            "usn": usn,
          }, where: 'id =?', whereArgs: [taskFieldId]);
        }
        await db.insert(taskValuesTable, {
          "tasks_fields": taskFieldId,
          "value": taskFieldValue
        });
        print(":: $taskFieldValue");

      }
      catch (e) {
        return false;
      }
    }
    return true;
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
  Future<TaskCommentModel> insertTaskComment(TaskCommentModel tasksComment) async{
    Database db = await this.database;
    int id=0;
    try{
      print('${tasksComment.toMap().toString()}');
      id=await db.insert(taskCommentTable, tasksComment.toMap());
    }
    catch(e){
      //await db(tasksTable, task.toMap());
    }
    tasksComment.id=id;
    return tasksComment;
  }
  Future<int> addStatusToTask({required TasksStatusesModel ts,int? resolution, required  bool update_usn}) async {
    Database db = await this.database;
    int id=0;
    try{
      //print('${tasksStatuses.toMap().toString()}');
      if(update_usn){
        int usn = await getUSN();
        ts.usn=usn;
      }
      Map<String,dynamic> upd={"status":ts.status.id};
      if(resolution!=null)
        upd["resolution"]=resolution;
      await db.update(tasksTable, upd, where: 'id =?', whereArgs: [ts.task.id]);
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
  Future<ResolutionGroupModel> insertResolutionGroup(ResolutionGroupModel resolutionGroup) async{
    Database db = await this.database;
    int id=0;
    try{
      id=await db.insert(resolutionGroupTable, resolutionGroup.toMap());
    }
    catch(e){
      //await db(tasksTable, task.toMap());
    }
    resolutionGroup.id=id;
    return resolutionGroup;
  }
  Future<int> getTemplateIdByServerId(int serverId) async {
    Database db = await this.database;
    final List<Map<String,dynamic>> templateMapList = await db.query(tasksTemplateTable, orderBy: "id desc",limit: 1,where: 'external_id =?', whereArgs: [serverId]);
    return templateMapList.first["id"]??0;//tasksMapList.isNotEmpty?TaskModel.fromMap(tasksMapList.first):null;
  }

  Future<TemplateModel> updateTemplateByServerId(TemplateModel template) async{
    Database db = await this.database;

    int templateId = await getTemplateIdByServerId(template.serverId);
    if(templateId!=0)
      await db.update(tasksTemplateTable, template.toMap(), where: 'id =?', whereArgs: [templateId]);
    template.id=templateId;
    return template;
  }
  Future<TaskCommentModel> updateTaskCommntByServerId(TaskCommentModel comment) async{
    Database db = await this.database;

    int templateId = await getCommentIdByServerId(comment.serverId);
    if(templateId!=0)
      await db.update(taskCommentTable, comment.toMap(), where: 'id =?', whereArgs: [templateId]);
    comment.id=templateId;
    return comment;
  }
  Future<int> getCommentIdByServerId(int? serverId) async {
    Database db = await this.database;
    final List<Map<String,dynamic>> phoneMapList = await db.query(taskCommentTable, orderBy: "id desc",limit: 1,where: 'external_id =?', whereArgs: [serverId]);
    return phoneMapList.first["id"]??0;//tasksMapList.isNotEmpty?TaskModel.fromMap(tasksMapList.first):null;
  }

  Future<TemplateModel> insertTemplate(TemplateModel template) async{
    Database db = await this.database;
    int id=0;
    try{
      id=await db.insert(tasksTemplateTable, template.toMap());
    }
    catch(e){
      //await db(tasksTable, task.toMap());
    }
    template.id=id;
    return template;
  }
  Future<int> getPhoneIdByServerId(int serverId) async {
    Database db = await this.database;
    final List<Map<String,dynamic>> phoneMapList = await db.query(tasksPhoneTable, orderBy: "id desc",limit: 1,where: 'external_id =?', whereArgs: [serverId]);
    return phoneMapList.first["id"]??0;//tasksMapList.isNotEmpty?TaskModel.fromMap(tasksMapList.first):null;
  }

  Future<PhoneModel> updatePhoneByServerId(PhoneModel phone) async{
    Database db = await this.database;

    int phoneId = await getTemplateIdByServerId(phone.serverId);
    if(phoneId!=0)
      await db.update(tasksPhoneTable, phone.toMap(), where: 'id =?', whereArgs: [phoneId]);
    phone.id=phoneId;
    return phone;
  }
  Future<bool> setTasksStatusServerID(int id, int serverId) async{
    Database db = await this.database;
    await db.update(tasksStatusesTable, {"external_id":serverId}, where: 'id =?', whereArgs: [id]);
    return true;
  }
  Future<bool> setFileServerID(int id, int serverId) async{
    Database db = await this.database;
    await db.update(fileTable, {"external_id":serverId}, where: 'id =?', whereArgs: [id]);
    return true;
  }
  Future<PhoneModel> insertPhone(PhoneModel phone) async{
    Database db = await this.database;
    int id=0;
    try{
      id=await db.insert(tasksPhoneTable, phone.toMap());
    }
    catch(e){
      //await db(tasksTable, task.toMap());
    }
    phone.id=id;
    return phone;
  }
Future<int> getPersonIdByServerId(int serverId) async {
    Database db = await this.database;
    final List<Map<String,dynamic>> personMapList = await db.query(tasksPersonTable, orderBy: "id desc",limit: 1,where: 'external_id =?', whereArgs: [serverId]);
    return personMapList.first["id"]??0;//tasksMapList.isNotEmpty?TaskModel.fromMap(tasksMapList.first):null;
  }

  Future<PersonModel> updatePersonByServerId(PersonModel person) async{
    Database db = await this.database;

    int personId = await getTemplateIdByServerId(person.serverId);
    if(personId!=0)
      await db.update(tasksPersonTable, person.toMap(), where: 'id =?', whereArgs: [personId]);
    person.id=personId;
    return person;
  }
  Future<PersonModel> insertPerson(PersonModel person) async{
    Database db = await this.database;
    int id=0;
    try{
      id=await db.insert(tasksPersonTable, person.toMap());
    }
    catch(e){
      //await db(tasksTable, task.toMap());
    }
    person.id=id;
    return person;
  }

  Future<EmployeeModel> insertEmployee(EmployeeModel employee) async{
    Database db = await this.database;
    int id=0;
    try{
      id=await db.insert(employeeTable, employee.toMap());
    }
    catch(e){
      //await db(tasksTable, task.toMap());
    }
    employee.id=id;
    return employee;
  }
  Future<int> getContractorIdByServerId(int serverId) async {
    Database db = await this.database;
    final List<Map<String,dynamic>> contractorMapList = await db.query(contractorTable, orderBy: "id desc",limit: 1,where: 'external_id =?', whereArgs: [serverId]);
    return contractorMapList.first["id"]??0;//tasksMapList.isNotEmpty?TaskModel.fromMap(tasksMapList.first):null;
  }

  Future<ContractorModel> updateContractorByServerId(ContractorModel contractor) async{
    Database db = await this.database;

    int contractorId = await getContractorIdByServerId(contractor.serverId);
    if(contractorId!=0)
      await db.update(contractorTable, contractor.toMap(), where: 'id =?', whereArgs: [contractorId]);
    contractor.id=contractorId;
    return contractor;


  }
  Future<int> getEmployeeIdByServerId(int serverId) async {
    Database db = await this.database;
    final List<Map<String,dynamic>> employeeMapList = await db.query(employeeTable, orderBy: "id desc",limit: 1,where: 'external_id =?', whereArgs: [serverId]);
    return employeeMapList.first["id"]??0;//tasksMapList.isNotEmpty?TaskModel.fromMap(tasksMapList.first):null;
  }

  Future<EmployeeModel> updateEmployeeByServerId(EmployeeModel employee) async{
    Database db = await this.database;

    int employeeId = await getEmployeeIdByServerId(employee.serverId);
    if(employeeId!=0)
      await db.update(employeeTable, employee.toMap(), where: 'id =?', whereArgs: [employeeId]);
    employee.id=employeeId;
    return employee;


  }
Future<int> getResolutionGroupIdByServerId(int serverId) async {
    Database db = await this.database;
    final List<Map<String,dynamic>> resolutionMapList = await db.query(resolutionGroupTable, orderBy: "id desc",limit: 1,where: 'external_id =?', whereArgs: [serverId]);
    return resolutionMapList.first["id"]??0;//tasksMapList.isNotEmpty?TaskModel.fromMap(tasksMapList.first):null;
  }

  Future<ResolutionGroupModel> updateResolutionGroupByServerId(ResolutionGroupModel resolutionGroup) async{
    Database db = await this.database;

    int resolutionGroupId = await getResolutionGroupIdByServerId(resolutionGroup.serverId);
    if(resolutionGroupId!=0)
      await db.update(resolutionGroupTable, resolutionGroup.toMap(), where: 'id =?', whereArgs: [resolutionGroupId]);
    resolutionGroup.id=resolutionGroupId;
    return resolutionGroup;


  }

  Future<ContractorModel> insertContractor(ContractorModel contractor) async{
    Database db = await this.database;
    int id=0;
    try{
      id=await db.insert(contractorTable, contractor.toMap());
    }
    catch(e){
      //await db(tasksTable, task.toMap());
    }
    contractor.id=id;
    return contractor;
  }
  Future<int> getTaskSelectionIdByServerId(int serverId) async {
    Database db = await this.database;
    final List<Map<String,dynamic>> taskSelectionMapList = await db.query(taskSelectionValuesTable, orderBy: "id desc",limit: 1,where: 'external_id =?', whereArgs: [serverId]);
    return taskSelectionMapList.first["id"]??0;//tasksMapList.isNotEmpty?TaskModel.fromMap(tasksMapList.first):null;
  }

  Future<int> updateTaskSelectionByServerId(SelectionValueModel selection) async{
    Database db = await this.database;

    int selectionId = await getTaskSelectionIdByServerId(selection.serverId);
    //print("address: ${selection.address}");
    if(selectionId!=0)
      await db.update(taskSelectionValuesTable, selection.toMap(), where: 'id =?', whereArgs: [selectionId]);
    //task.id=taskId;
    return selectionId;

  }
  Future<SelectionValueModel> insertTaskSelection(SelectionValueModel selection) async{
    Database db = await this.database;
    int id=0;
    try{
      id=await db.insert(taskSelectionValuesTable, selection.toMap());
    }
    catch(e){
      //await db(tasksTable, task.toMap());
    }
    selection.id=id;
    return selection;
  }
  Future<void> insertResolutuionGroupRelation(int id, int resolutionGroupId) async{
    Database db = await this.database;
    //int id=0;
    try{
      await db.insert(resolutionGroup2ResolutionRelationTable, {"resolution":id,"resolution_group":resolutionGroupId});
    }
    catch(e){
      //await db(tasksTable, task.toMap());
    }
    //selection.id=id;
    //return selection;
  }
  Future<void> deleteResolutuionGroupRelation(int id) async{
    Database db = await this.database;
    //int id=0;
    try{
      await db.delete(resolutionGroup2ResolutionRelationTable, where: 'resolution =?', whereArgs: [id]);
      //await db.insert(resolutionGroup2ResolutionRelationTable, {"resolution":id,"resolution_group":resolutionGroupId});
    }
    catch(e){
      //await db(tasksTable, task.toMap());
    }
    //selection.id=id;
    //return selection;
  }

//UPDATE
  Future<int> updateTask(TaskModel task) async{
    Database db = await this.database;
    return await db.update(tasksTable, task.toMap(), where: 'id =?', whereArgs: [task.id]);

  }
  Future<int> updateTaskByServerId(TaskModel task) async{
    Database db = await this.database;

    int taskId = await getTaskIdByServerId(task.serverId);
    print("address: ${task.address}");
    if(taskId!=0)
      await db.update(tasksTable, task.toMap(), where: 'id =?', whereArgs: [taskId]);
    //task.id=taskId;
    return taskId;
  }


  Future<TasksStatusesModel> updateTasksStatusesByServerId(TasksStatusesModel task) async{
    Database db = await this.database;

    int tasksStatusesId = await getTasksStatusesIdByServerId(task.serverId);
    if(tasksStatusesId!=0)
      await db.update(tasksStatusesTable, task.toMap(), where: 'id =?', whereArgs: [tasksStatusesId]);
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
    return tasksMapList.isNotEmpty?TaskStatusModel.fromMap(map:tasksMapList.first):null;
  }

  Future<int> getTaskIdByServerId(int serverId) async {
    Database db = await this.database;
    final List<Map<String,dynamic>> tasksMapList = await db.query(tasksTable, orderBy: "id desc",limit: 1,where: 'external_id =?', whereArgs: [serverId]);
    return tasksMapList.first["id"]??0;//tasksMapList.isNotEmpty?TaskModel.fromMap(tasksMapList.first):null;
  }

  Future<int> getTasksFieldsTabIdByServerId(int? serverId) async {
    Database db = await this.database;
    final List<Map<String,dynamic>> tasksMapList = await db.query(tasksFieldsTabTable, orderBy: "id desc",limit: 1,where: 'external_id =?', whereArgs: [serverId]);
    return tasksMapList.first["id"]??0;//tasksMapList.isNotEmpty?TaskModel.fromMap(tasksMapList.first):null;
  }
  Future<int> getTaskSelectionValueIdByServerId(int serverId) async {
    Database db = await this.database;
    final List<Map<String,dynamic>> tasksMapList = await db.query(taskSelectionValuesTable, orderBy: "id desc",limit: 1,where: 'external_id =?', whereArgs: [serverId]);
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
    return tasksMapList.isNotEmpty?TaskStatusModel.fromMap(map:tasksMapList.first):null;
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

  Future<int> insertTaskField2taskSelectionValueRelation(fieldId,id) async {
    print("insertTaskField2taskSelectionValueRelation");
    Database db = await this.database;
    int rid=0;
    try{
      await db.delete(taskSelectionValuesRelationTable, where: 'tasks_fields =?', whereArgs: [fieldId]);
      rid=await db.insert(taskSelectionValuesRelationTable, {"tasks_fields": fieldId,"tasks_selection_values":id});
    }
    catch(e){
      print("$e");
      //await db(tasksTable, task.toMap());
    }
    //taskStatus.id=id;
    return rid;
  }

  //updateStatusByServerId(TaskStatusModel taskStatusModel) async {}
  Future<int?> updateTaskStatusByServerId(TaskStatusModel taskStatus) async{
    Database db = await this.database;

    TaskStatusModel? ts = await getTaskStatusByServerId(taskStatus.serverId);
    print("TaskStatusModel: serverId: ${taskStatus.serverId}, id: ${ts?.id}");
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
      await db.update(taskFieldTable, taskFieldModel.toMap(), where: 'id =?', whereArgs: [taskId]);
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
      await db.update(tasksFieldsTable, taskFieldModel.toMap(), where: 'id =?', whereArgs: [taskId]);
    //task.id=taskId;
    return taskId;
  }
  Future<int> getTasksFieldIdByServerId(int serverId) async {
    Database db = await this.database;
    final List<Map<String,dynamic>> tasksMapList = await db.query(tasksFieldsTable, orderBy: "id desc",limit: 1,where: 'external_id =?', whereArgs: [serverId]);
    return tasksMapList.first["id"]??0;//tasksMapList.isNotEmpty?TaskModel.fromMap(tasksMapList.first):null;
  }

}