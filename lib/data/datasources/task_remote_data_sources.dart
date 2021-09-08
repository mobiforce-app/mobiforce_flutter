import 'dart:io';

import 'package:mobiforce_flutter/core/error/exception.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class TaskRemoteDataSources{
  Future<List<TaskModel>>searchTask(String query);
  Future<List<TaskModel>>getAllTask(int page);
}

class TaskRemoteDataSourcesImpl implements TaskRemoteDataSources
{
  final http.Client client;
  final SharedPreferences sharedPreferences;
  TaskRemoteDataSourcesImpl({required this.client,required this.sharedPreferences});
  @override
  Future<List<TaskModel>> searchTask(String query) => _getTaskFromUrl(url: "https://mobifors111.mobiforce.ru/api2.0/get-tasks.php", page:0);

  @override
  Future<List<TaskModel>> getAllTask(int page) => _getTaskFromUrl(url: "https://mobifors111.mobiforce.ru/api2.0/get-tasks.php", page:page);


  Future<List<TaskModel>> _getTaskFromUrl({required String url,required int page}) async{
    final token=sharedPreferences.getString("access_token");
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
    }
  }
  
}