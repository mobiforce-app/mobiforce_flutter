import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/core/error/exception.dart';
import 'package:mobiforce_flutter/data/models/employee_model.dart';
import 'package:mobiforce_flutter/data/models/file_model.dart';
import 'package:mobiforce_flutter/data/models/resolution_group_model.dart';
import 'package:mobiforce_flutter/data/models/resolution_model.dart';
import 'package:mobiforce_flutter/data/models/task_comment_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:http/http.dart' as http;
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
  Future<TaskEntity>createTaskOnServer(TaskEntity task);
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
    final String url = "https://mobifors111.mobiforce.ru/api2.0/create-task.php";
    final token=sharedPreferences.getString("access_token");

    print(token);
    try{
      final int selfId = sharedPreferences.getInt("self_id")??0;
      task.employees=[EmployeeModel(id: 0, usn: 0, serverId: selfId, name: "", webAuth: false, mobileAuth: true)].toList();
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
        final t = await db.getTask(taskInsertId);
        print("task_readed[$taskInsertId] ${(t as TaskModel).toMap()}");
        return t;
      }
      else{
        print("My exception");
        throw ServerException();
      }
    }
    catch (error) {
      print("error!!! $error");
      throw ServerException();
    }

  }//_getTaskFromUrl(url: "https://mobifors111.mobiforce.ru/api2.0/get-templates.php", page:page);


  @override
  Future<List<TemplateModel>> getAllTemplates(int page) => _getTaskFromUrl(url: "https://mobifors111.mobiforce.ru/api2.0/get-templates.php", page:page);


  Future<List<TemplateModel>> _getTaskFromUrl({required String url,required int page}) async{
    //return await db.getTasks(page);
    final token=sharedPreferences.getString("access_token");
    print(token);
    try{
      Map data = {
        'filters': '{"groupOp":"AND","rules":[]}',
        'nd': 1629978655643,
        'page': 1,
        'rows': 30,
        'sidx': 'ID',
        'sord': 'asc',
        'tableId': 'tasktemplate_grid',
        'updateCounter': 0,
        '_search': true
      };
      final response = await client.post(Uri.parse(url),headers:{'Content-Type':"application/json","AUTHORIZATION":"key=$token"},body: json.encode(data));
      if(response.statusCode == 200){
        final templates = json.decode(response.body);
        //print("ok!"+response.body);
        return (templates['results'] as List).map((task)=> TemplateModel.fromJson(task)).toList();
      }
      else{
        print("My exception");
        throw ServerException();
      }
    }
    catch (error) {
      print("error!!! $error");
      throw ServerException();
    }
  }
  
}