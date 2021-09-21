import 'dart:io';

import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/core/error/exception.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:http/http.dart' as http;
import 'package:mobiforce_flutter/data/models/tasksstatuses_model.dart';
import 'package:mobiforce_flutter/data/models/taskstatus_model.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class TaskRemoteDataSources{
  Future<List<TaskModel>>searchTask(String query);
  Future<List<TaskModel>>getAllTask(int page);
  Future<TaskModel>getTask(int id);
  Future<List<TaskStatusModel>>getTaskStatusGraph(int? id);
  Future<TaskModel> setTaskStatus({required int status,required int task});

}

class TaskRemoteDataSourcesImpl implements TaskRemoteDataSources
{
  final http.Client client;
  final SharedPreferences sharedPreferences;
  final DBProvider db;
  TaskRemoteDataSourcesImpl({required this.client,required this.sharedPreferences, required this.db});


  @override
  Future<List<TaskModel>> searchTask(String query) => _getTaskFromUrl(url: "https://mobifors111.mobiforce.ru/api2.0/get-tasks.php", page:0);

  @override
  Future<List<TaskModel>> getAllTask(int page) => _getTaskFromUrl(url: "https://mobifors111.mobiforce.ru/api2.0/get-tasks.php", page:page);

  @override
  Future<List<TaskStatusModel>> getTaskStatusGraph(int ?id) async
  {
    return await db.getNextStatuses(id);
  }
  @override
  Future<TaskModel> getTask(int id) async{
    return await db.getTask(id);
  }
  @override
  Future<TaskModel> setTaskStatus({required int status,required int task}) async{
    var date = new DateTime.now();
    int d = (date.toUtc().millisecondsSinceEpoch/1000).toInt();
    TasksStatusesModel ts = TasksStatusesModel(id:0,usn:0,serverId: null, statusId:status, serverStatusId: 0,task:task,createdTime: d, manualTime: d, lat: 0.0, lon:0.0, color:"", name: "", dirty:true);

    await db.addStatusToTask(ts);
    return await db.getTask(task);
  }


  Future<List<TaskModel>> _getTaskFromUrl({required String url,required int page}) async{
    return await db.getTasks(page);
    /*final token=sharedPreferences.getString("access_token");
    print(token);
    try{
      Map data = {
        'filters': '{"groupOp":"AND","rules":[]}',
        'nd': 1629978655643,
        'page': page,
        'rows': 30,
        'sidx': 'ID',
        'sord': 'asc',
        'tableId': 'clients_grid',
        'updateCounter': 0,
        '_search': true
      };
      final response = await client.post(Uri.parse(url),headers:{'Content-Type':"application/json","AUTHORIZATION":"key=$token"},body: json.encode(data));
      if(response.statusCode == 200){
        final tasks = json.decode(response.body);
        return (tasks['results'] as List).map((task)=> TaskModel.fromJson(task)).toList();
      }
      else{
        print("My exception");
        throw ServerException();
      }
    }
    catch (error) {
      print("error!!! $error");
      throw ServerException();
    }*/
  }
  
}