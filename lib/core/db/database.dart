import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobiforce_flutter/data/models/contractor_model.dart';
import 'package:mobiforce_flutter/data/models/employee_model.dart';
import 'package:mobiforce_flutter/data/models/person_model.dart';
import 'package:mobiforce_flutter/data/models/phone_model.dart';
import 'package:mobiforce_flutter/data/models/resolution_model.dart';
import 'package:mobiforce_flutter/data/models/selection_value_model.dart';
import 'package:mobiforce_flutter/data/models/task_life_cycle_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/taskfield_model.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/data/models/tasksstatuses_model.dart';
import 'package:mobiforce_flutter/data/models/taskstatus_model.dart';
import 'package:mobiforce_flutter/data/models/template_model.dart';
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
  String taskSelectionValuesTable="taskselectionvalue";
  String taskSelectionValuesRelationTable="taskselectionvaluerelation";
  String taskStatusTable="taskstatus";
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
        'CREATE TABLE IF NOT EXISTS  $usnCountersTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'object_type TEXT, '
            'usn_counter INTEGER'
            ')');
    await db.insert(usnCountersTable, {'object_type':'task_option','usn_counter':0});


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
            'author int, '
            'template int, '
            'address TEXT, '
            'name TEXT)');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS  $resolutionTable ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'dirty INTEGER, '
            'external_id INTEGER UNIQUE, '
            'name TEXT)');

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
    await db.execute('DROP TABLE IF EXISTS $tasksTable');
    await db.execute('DROP TABLE IF EXISTS $resolutionTable');
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
    _createDB(db, 1);
  }
//READ
  Future<List<TasksFieldsModel>> readTasksFieldsUpdates(int localUSN) async{
   //return null;
    Database db = await this.database;
    final List<Map<String,dynamic>> tasksFieldsMapList = await db.rawQuery("SELECT t1.*, "
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
        "WHERE t1.usn > ? ORDER BY t1.usn ASC",[localUSN]);

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

    return tasksFieldsMapList.map((field) => TasksFieldsModel.fromMap(field,tasksFieldsSelectionValuesMap)).toList();
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
    final List<Map<String,dynamic>> tasksMapList = await db.query(tasksTable, orderBy: "id desc",limit: 1,where: 'id =?', whereArgs: [id]);
    final List<Map<String,dynamic>> taskStatusMapList = await db.query(taskStatusTable, orderBy: "id desc",limit: 1,where: 'id =?', whereArgs: [tasksMapList.first['status']]);
    final List<Map<String,dynamic>> tasksStatusesMapList = await db.rawQuery("SELECT t1.*, t2.name, t2.color FROM $tasksStatusesTable as t1 LEFT JOIN $taskStatusTable as t2 ON t1.task_status = t2.id WHERE t1.task = ? ORDER BY t1.id DESC",[id]);
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
    return TaskModel.fromMap(
        taskMap:tasksMapList.first,
        statusMap:taskStatusMapList.first,
        statusesMap: tasksStatusesMapList,
        tasksFieldsMap: tasksFieldsMapList,
        tasksFieldsSelectionValuesMap:reMapTasksFieldsSelectionValues(tasksFieldsSelectionValuesMapList));
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
      tasksList.add(TaskModel.fromMap(taskMap: taskMap,statusMap: taskStatusMapList.first));
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

  Future<bool> updateTaskFieldSelectionValue({required int taskFieldId,int? taskFieldSelectionValue}) async{
    Database db = await this.database;

    try{
      await db.delete(taskSelectionValuesRelationTable, where: 'tasks_fields =?', whereArgs: [taskFieldId]);
    }
    catch(e){
      //await db(tasksTable, task.toMap());
    }
    if(taskFieldSelectionValue!=null) {
      try {
        int usn = await getUSN();
        await db.update(tasksFieldsTable, {
          "usn":usn,
        }, where: 'id =?', whereArgs: [taskFieldId]);
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
  Future<bool> updateTaskFieldValue({required int taskFieldId,String? taskFieldValue}) async{
    Database db = await this.database;
    try{
      await db.delete(taskValuesTable, where: 'tasks_fields =?', whereArgs: [taskFieldId]);
    }
    catch(e){
      //await db(tasksTable, task.toMap());
    }
    if(taskFieldValue!=null) {
      try {
        int usn = await getUSN();
        await db.update(tasksFieldsTable, {
          "usn":usn,
        }, where: 'id =?', whereArgs: [taskFieldId]);
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
  Future<int> getTemplateIdByServerId(int serverId) async {
    Database db = await this.database;
    final List<Map<String,dynamic>> templateMapList = await db.query(tasksTemplateTable, orderBy: "id desc",limit: 1,where: 'external_id =?', whereArgs: [serverId]);
    return templateMapList.first["id"]??0;//tasksMapList.isNotEmpty?TaskModel.fromMap(tasksMapList.first):null;
  }

  Future<TemplateModel> updateTemplateByServerId(TemplateModel template) async{
    Database db = await this.database;

    int templateId = await getTemplateIdByServerId(template.serverId);
    if(templateId!=0)
      await db.update(tasksTemplateTable, template.toMap(), where: 'external_id =?', whereArgs: [templateId]);
    template.id=templateId;
    return template;
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
      await db.update(tasksPhoneTable, phone.toMap(), where: 'external_id =?', whereArgs: [phoneId]);
    phone.id=phoneId;
    return phone;
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
      await db.update(tasksPersonTable, person.toMap(), where: 'external_id =?', whereArgs: [personId]);
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
      await db.update(contractorTable, contractor.toMap(), where: 'external_id =?', whereArgs: [contractorId]);
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
      await db.update(employeeTable, employee.toMap(), where: 'external_id =?', whereArgs: [employeeId]);
    employee.id=employeeId;
    return employee;


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

  Future<int> insertTaskField2taskSelectionValueRelation(fieldId,id) async {
    print("insertTaskField2taskSelectionValueRelation");
    Database db = await this.database;
    int rid=0;
    try{
      rid=await db.insert(taskSelectionValuesRelationTable, {"tasks_fields":fieldId,"tasks_selection_values":id});
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