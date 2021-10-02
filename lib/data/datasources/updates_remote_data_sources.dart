import 'dart:io';

import 'package:mobiforce_flutter/core/error/exception.dart';
//import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mobiforce_flutter/data/models/authorization_model.dart';
import 'package:mobiforce_flutter/data/models/sync_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';

abstract class UpdatesRemoteDataSources{
  //Future<LoginModel>searchTask(String query);
 // Future
  Future<SyncModel>getDataList({required String domain, required String accessToken, required int lastSyncTime, required int lastUpdateCount,required String objectType,required List<dynamic> Function(dynamic) mapObjects });
  Future<bool> sendUpdate({required String domain, required String accessToken, required String objectType, Map<String,dynamic> mapObjects });
}

class UpdatesRemoteDataSourcesImpl implements UpdatesRemoteDataSources
{
  final http.Client client;
  UpdatesRemoteDataSourcesImpl({required this.client});
 // @override
 // Future<List<TaskModel>> searchTask(String query) => _getTaskFromUrl(url: "https://mobifors111.mobiforce.ru/api2.0/get-tasks.php", page:0);

 // @override
 // Future<List<TaskModel>> getAllTask(int page) => _getTaskFromUrl(url: "https://mobifors111.mobiforce.ru/api2.0/get-tasks.php", page:page);


  @override
  Future<bool> sendUpdate({required String domain, required String accessToken, required String objectType, Map<String,dynamic>? mapObjects })
  async{

    try{
      Map data = {
        'objectType':objectType,
        'data': mapObjects
      };
      print("domain=$domain, access_token=$accessToken, objectType = $objectType");
      final response = await client.post(Uri.parse("https://$domain/api2.0/send-update.php"),

          headers:{
            'Content-Type':"application/json",
            HttpHeaders.authorizationHeader: "key=\"$accessToken\"",
          },body: json.encode(data));
      if(response.statusCode == 200){
        final auth = json.decode(response.body);
        print(response.body);
        return true;
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
    return true;
  }
  @override
  Future<SyncModel> getDataList({
    required String domain,
    required  String accessToken,
    required int lastSyncTime,
    required  int lastUpdateCount,
    required String objectType,
    required List<dynamic> Function(dynamic) mapObjects
  }) async{
    //await Future.delayed(const Duration(seconds: 5), (){});
    //try{
      Map data = {
        'lastUpdateCount': lastUpdateCount,
        'lastSyncTime': lastSyncTime,
        'objectType':objectType,
        // 'pass': pass
      };
      print("domain=$domain, access_token=$accessToken, lastUpdateCount = $lastUpdateCount, objectType = $objectType, lastSyncTime = $lastSyncTime");
      final response = await client.post(Uri.parse("https://$domain/api2.0/get-updates.php"),

          headers:{
            'Content-Type':"application/json",
            HttpHeaders.authorizationHeader: "key=\"$accessToken\"",
          },body: json.encode(data));
      if(response.statusCode == 200){
        final auth = json.decode(response.body);
        print(response.body);
        return SyncModel.fromJson(auth['results'],mapObjects);
      }
      else{
        print("My exception");
        throw ServerException();
      }
    //}
    /*catch (error) {
      print("error!!! $error");
      throw ServerException();
    }*/
  }
  
}