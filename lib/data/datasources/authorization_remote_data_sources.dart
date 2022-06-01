import 'dart:io';

import 'package:mobiforce_flutter/core/error/exception.dart';
//import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mobiforce_flutter/data/models/authorization_model.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract class AuthorizationRemoteDataSources{
  //Future<LoginModel>searchTask(String query);
  Future<AuthorizationModel>firstLogin({required String domain, required String login,required  String pass, String? fcmToken});
  //Future<int>logout();
}

class AuthorizationRemoteDataSourcesImpl implements AuthorizationRemoteDataSources
{
  final http.Client client;
  AuthorizationRemoteDataSourcesImpl({required this.client});
 // @override
 // Future<List<TaskModel>> searchTask(String query) => _getTaskFromUrl(url: "https://mobifors111.mobiforce.ru/api2.0/get-tasks.php", page:0);

 // @override
 // Future<List<TaskModel>> getAllTask(int page) => _getTaskFromUrl(url: "https://mobifors111.mobiforce.ru/api2.0/get-tasks.php", page:page);
  /*@override
  Future<int> logout() async {
    return 1;
  }*/
  @override
  Future<AuthorizationModel> firstLogin({required String domain,required  String login,required  String pass, String? fcmToken}) async{

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    try{
      print("fcmToken++: $fcmToken");
      Map data = {
        'domain': domain,
        'login': login,
        'pass': pass,
        'fcmToken': fcmToken,
        'appName': appName,
        'packageName': packageName,
        'version': version,
        'buildNumber': buildNumber,
      };
      final response = await client.post(Uri.parse("https://exchange.mobiforce.ru/api2.0/autorization.php"),headers:{'Content-Type':"application/json"},body: json.encode(data));
      if(response.statusCode == 200){
        final auth = json.decode(response.body);
        print(response.body);
        return AuthorizationModel.fromJson(auth);
      }
      else{
        print("My exception");
        throw ServerException();
      }
    }
    catch (error) {
      print("error!!!+1 $error");
      throw ServerException();
    }
  }
  
}