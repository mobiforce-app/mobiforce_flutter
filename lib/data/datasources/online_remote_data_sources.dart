import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/core/error/exception.dart';
import 'package:mobiforce_flutter/data/models/contractor_model.dart';
import 'package:mobiforce_flutter/data/models/employee_model.dart';
import 'package:mobiforce_flutter/data/models/equipment_model.dart';
import 'package:mobiforce_flutter/data/models/file_model.dart';
import 'package:mobiforce_flutter/data/models/person_model.dart';
import 'package:mobiforce_flutter/data/models/phone_model.dart';
import 'package:mobiforce_flutter/data/models/resolution_group_model.dart';
import 'package:mobiforce_flutter/data/models/resolution_model.dart';
import 'package:mobiforce_flutter/data/models/task_comment_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:http/http.dart' as http;
import 'package:mobiforce_flutter/data/models/taskfield_model.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/data/models/tasksstatuses_model.dart';
import 'package:mobiforce_flutter/data/models/taskstatus_model.dart';
import 'package:mobiforce_flutter/data/models/template_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_life_cycle_node_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskfield_entity.dart';
import 'package:mobiforce_flutter/domain/entity/tasksstatuses_entity.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class OnlineRemoteDataSources{
  Future<List<TemplateModel>>getAllTemplates(int page);
  Future<List<ContractorModel>>getAllContractors(String name);
  Future<List<EquipmentModel>>getAllEquipments({ int? contractor, String? query});
  Future<TaskEntity>createTaskOnServer(TaskEntity task);
  Future<ContractorModel> getCurrentContractor(int id);
  Future<TemplateModel> getCurrentTemplate(int id);
  Future<TaskModel> getCurrentTask(int id);
  Future<EquipmentModel> getCurrentEquipment(int id);
}

class OnlineRemoteDataSourcesImpl implements OnlineRemoteDataSources
{
  final http.Client client;
  final SharedPreferences sharedPreferences;
  final DBProvider db;
  OnlineRemoteDataSourcesImpl({required this.client,required this.sharedPreferences, required this.db});


  @override
  Future<TaskEntity> createTaskOnServer (TaskEntity task) async
  {
    final String url = "https://agfa.mobiforce.ru/api2.0/create-task.php";
    final token=sharedPreferences.getString("access_token");

    print(token);
    try{
      final int selfId = sharedPreferences.getInt("self_id")??0;
      //task.equipment=EquipmentModel(id: 0, usn: 0, serverId: 4052, name: "");
      task.employees=[EmployeeModel(id: 0, usn: 0, serverId: selfId, name: "", login: "", webAuth: false, mobileAuth: true)].toList();
      //task.author=EmployeeModel(id: 0, usn: 0, serverId: selfId, name: "", webAuth: false, mobileAuth: true);
      Map data = (task as TaskModel).toJson();
      print("data ${data.toString()}");
      final response = await client.post(Uri.parse(url),headers:{'Content-Type':"application/json","AUTHORIZATION":"key=$token"},body: json.encode(data));
      if(response.statusCode == 200){
        final taskJson = json.decode(response.body);
        print("ok!"+response.body);
        task = TaskModel.fromJson(taskJson);
        print("taskJson ${taskJson.toString()}");
        print("task ${task.toMap()}");
        int taskInsertId = await task.insertToDB(db);
        print("taskInsertId $taskInsertId");
        final t = await db.getTask(taskInsertId, null);
        print("task_readed[$taskInsertId] ${(t as TaskModel).toMap()}");
        return t;
      }
      else{
        print("My exception");
        throw ServerException();
      }
    }
    catch (error) {
      print("error!!!+3 $error");
      throw ServerException();
    }

  }//_getTaskFromUrl(url: "https://mobifors111.mobiforce.ru/api2.0/get-templates.php", page:page);


  @override
  Future<List<TemplateModel>> getAllTemplates(int page) async {
    var results = await _getTableFromUrl(
        url: "https://agfa.mobiforce.ru/api2.0/get-templates.php",
        page: page,
        gridName: "tasktemplate_grid",
        rules: '{"groupOp":"AND","rules":[]}'
    );
    return (results as List).map((task)=> TemplateModel.fromJson(task)).toList();
  }
  @override
  //Future<List<TemplateModel>> getAllContractors(String name) => _getTableFromUrl(url: "https://mobifors111.mobiforce.ru/api2.0/get-templates.php", page:0,gridName:"tasktemplate_grid");
  Future<List<ContractorModel>> getAllContractors(String name) async {
    var results = await _getTableFromUrl(
        url: "https://agfa.mobiforce.ru/api2.0/get-contractors.php",
        page: 0,
        gridName: "contractor_grid",
        rules: '{"groupOp":"AND","rules":[],"groups":[{"groupOp":"OR","rules":[{"field":"name","op":"cn","data":"$name"},{"field":"address","op":"cn","data":"$name"},{"field":"parent","op":"cn","data":"$name"},{"field":"favourites","op":"cn","data":"$name"},{"field":"employee","op":"cn","data":"$name"}],"groups":[]}]}'
    );
    return (results as List).map((task)=> ContractorModel.fromJson(task)).toList();
  }
  @override
  Future<List<EquipmentModel>>getAllEquipments({String? query, int? contractor}) async {
    String contractorStr="";
    if(contractor!=null)
    {
      contractorStr='{"field":"contractor","op":"cn","data":"$contractor"}';
    }
    print("contractorStr $contractorStr");
    var results = await _getTableFromUrl(
        url: "https://agfa.mobiforce.ru/api2.0/get-equipments.php",
        page: 0,
        gridName: "equipment_grid",
//        rules: '{"groupOp":"AND","rules":[]}'
        rules: query==null?'{"groupOp":"AND","rules":[$contractorStr]}':'{"groupOp":"AND","rules":[$contractorStr],"groups":[{"groupOp":"OR","rules":[{"field":"description","op":"cn","data":"$query"},{"field":"name","op":"cn","data":"$query"},{"field":"inventory_number","op":"cn","data":"$query"},{"field":"contractor_name","op":"cn","data":"$query"},{"field":"model","op":"cn","data":"$query"},{"field":"manufacture","op":"cn","data":"$query"},{"field":"equipment_type","op":"cn","data":"$query"},{"field":"employee_name","op":"cn","data":"$query"}],"groups":[]}]}'
    );
    return (results as List).map((task)=> EquipmentModel.fromJson(task)).toList();
  }

  Future<ContractorModel> getCurrentContractor(int id) async {
    var results = await _getObjectFromUrl(
        url: "https://agfa.mobiforce.ru/api2.0/get-contractor.php?id=$id",
    );
    ContractorModel contractor = ContractorModel.fromJson(results);
    //List<PhoneModel> phones=[];
    if(contractor.phones!=null)
      await Future.forEach(contractor.phones!, (PhoneModel element) async {
        element.temp=true;
        element.serverId=null;
        int id = await element.insertToDB(db);
        element.id = id;
        //phones.add(element);
      });
    //contractor.phones=phones;
    List<PersonModel> persons=[];
    if(contractor.persons!=null)
      await Future.forEach(contractor.persons!, (PersonModel person) async {
        person.temp=true;
        person.contractorPersonServerId=person.serverId;
        person.serverId=null;
        person.phones?.forEach((element) {element.temp=true;});
        int id = await person.insertToDB(db);
        person.id = id;
        persons.add(person);
      });
    contractor.persons=persons;

    return contractor;
  }
  Future<EquipmentModel> getCurrentEquipment(int id) async {
    var results = await _getObjectFromUrl(
        url: "https://agfa.mobiforce.ru/api2.0/get-equipment.php?id=$id",
    );
    EquipmentModel equipment = EquipmentModel.fromJson(results);
    //List<PhoneModel> phones=[];
    /*if(contractor.phones!=null)
      await Future.forEach(contractor.phones!, (PhoneModel element) async {
        element.temp=true;
        element.serverId=null;
        int id = await element.insertToDB(db);
        element.id = id;
        //phones.add(element);
      });
    //contractor.phones=phones;
    List<PersonModel> persons=[];
    if(contractor.persons!=null)
      await Future.forEach(contractor.persons!, (PersonModel person) async {
        person.temp=true;
        person.serverId=null;
        person.phones?.forEach((element) {element.temp=true;});
        int id = await person.insertToDB(db);
        person.id = id;
        persons.add(person);
      });
    contractor.persons=persons;
    */
    return equipment;
  }
  Future<TaskModel> getCurrentTask(int id) async {

    var results = await _getObjectFromUrl(
        url: "https://agfa.mobiforce.ru/api2.0/get-task.php?id=$id",
    );
    print("results $results");
    TaskModel task = TaskModel.fromJson(results);
    //task.insertToDB(db);
    int taskInsertId = await task.insertToDB(db);
    task = await db.getTask(taskInsertId, null);
    //List<PhoneModel> phones=[];
    /*if(contractor.phones!=null)
      await Future.forEach(contractor.phones!, (PhoneModel element) async {
        element.temp=true;
        element.serverId=null;
        int id = await element.insertToDB(db);
        element.id = id;
        //phones.add(element);
      });
    //contractor.phones=phones;
    List<PersonModel> persons=[];
    if(contractor.persons!=null)
      await Future.forEach(contractor.persons!, (PersonModel person) async {
        person.temp=true;
        person.serverId=null;
        person.phones?.forEach((element) {element.temp=true;});
        int id = await person.insertToDB(db);
        person.id = id;
        persons.add(person);
      });
    contractor.persons=persons;
    */
    return task;
  }

Future<TemplateModel> getCurrentTemplate(int id) async {
    var results = await _getObjectFromUrl(
        url: "https://agfa.mobiforce.ru/api2.0/get-template.php?id=$id",
    );
    TemplateModel tm = TemplateModel.fromJson(results);
    List<TasksFieldsModel> tfm = [];
    if(tm.propsList!=null) {
      int fid=1;
      await Future.forEach(tm.propsList!, (TasksFieldsModel element) async {
        element.tab = await db.getTasksFieldsTabIdByServerId(element.tabServerId);
        element.id=fid++;
        print("idddd $fid");
        if(element.taskField!=null) {
          int id = await element.taskField!.insertToDB(db);
          element.taskField!.id = id;

        }
        tfm.add(element);
      });
    }
    tm.propsList=tfm;
    tm.propsList!.forEach((element) { print("idx ${element.id}");});
    return tm;
  }


  Future<List> _getTableFromUrl({required String url,required int page, required String gridName, required String rules}) async{
    //return await db.getTasks(page);
    print("getData $rules");
    final token=sharedPreferences.getString("access_token");
    print(token);
    try{
      Map data = {
        'filters': rules,
        'nd': 1629978655643,
        'page': 1,
        'rows': 30,
        'sidx': 'name',
        'sord': 'asc',
        'tableId': gridName,
        'updateCounter': 0,
        '_search': true
      };
      final response = await client.post(Uri.parse(url),headers:{'Content-Type':"application/json","AUTHORIZATION":"key=$token"},body: json.encode(data));
      if(response.statusCode == 200){
        print("response.body ${response.body}");
        final templates = json.decode(response.body);
        //print("ok!"+response.body);
        return templates['results'];//(templates['results'] as List).map((task)=> TemplateModel.fromJson(task)).toList();
      }
      else{
        print("My exception");
        throw ServerException();
      }
    }
    catch (error) {
      print("error!!!+4 $error");
      throw ServerException();
    }
  }
  Future<Map<String, dynamic>> _getObjectFromUrl({required String url,}) async{
    //return await db.getTasks(page);
    //print("getData $rules");
    final token=sharedPreferences.getString("access_token");
    print(token);
    try{

      final response = await client.get(Uri.parse(url),headers:{'Content-Type':"application/json","AUTHORIZATION":"key=$token"});
      if(response.statusCode == 200){
        print("response.body ${response.body}");
        final templates = json  .decode(response.body);
        //print("ok!"+response.body);
        return templates['results'];//(templates['results'] as List).map((task)=> TemplateModel.fromJson(task)).toList();
      }
      else{
        print("My exception");
        throw ServerException();
      }
    }
    catch (error) {
      print("error!!!+5 $error");
      throw ServerException();
    }
  }

}