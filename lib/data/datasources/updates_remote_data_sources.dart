import 'dart:io';

import 'package:mobiforce_flutter/core/error/exception.dart';
//import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mobiforce_flutter/data/models/authorization_model.dart';
import 'package:mobiforce_flutter/data/models/sync_model.dart';

abstract class UpdatesRemoteDataSources{
  //Future<LoginModel>searchTask(String query);
  Future<SyncModel>getDataList({required String domain, required String accessToken, required int lastSyncTime, required int lastUpdateCount});
}

class UpdatesRemoteDataSourcesImpl implements UpdatesRemoteDataSources
{
  final http.Client client;
  UpdatesRemoteDataSourcesImpl({required this.client});
 // @override
 // Future<List<TaskModel>> searchTask(String query) => _getTaskFromUrl(url: "https://mobifors111.mobiforce.ru/api2.0/get-tasks.php", page:0);

 // @override
 // Future<List<TaskModel>> getAllTask(int page) => _getTaskFromUrl(url: "https://mobifors111.mobiforce.ru/api2.0/get-tasks.php", page:page);


  Future<SyncModel> getDataList({
    required String domain,required  String accessToken,required int lastSyncTime,required  int lastUpdateCount}) async{
    await Future.delayed(const Duration(seconds: 5), (){});
    try{
      Map data = {
        'lastUpdateCount': lastUpdateCount,
        'lastSyncTime': lastSyncTime,
       // 'pass': pass
      };
      print("domain=$domain, access_token=$accessToken");
      final response = await client.post(Uri.parse("https://$domain/api2.0/get-updates.php"),

          headers:{
            'Content-Type':"application/json",
            HttpHeaders.authorizationHeader: "key=\"$accessToken\"",
          },body: json.encode(data));
      if(response.statusCode == 200){
        final auth = json.decode(response.body);
        print(response.body);
        return SyncModel.fromJson(auth['results']);
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