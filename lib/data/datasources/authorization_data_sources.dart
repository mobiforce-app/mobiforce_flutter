import 'dart:io';

import 'package:mobiforce_flutter/core/error/exception.dart';
//import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mobiforce_flutter/data/models/authorization_model.dart';
import 'package:mobiforce_flutter/domain/entity/user_setting_entity.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/db/database.dart';
import '../../domain/entity/employee_entity.dart';

abstract class AuthorizationDataSource{
  //Future<LoginModel>searchTask(String query);
  //Future<AuthorizationModel>firstLogin({required String domain, required String login,required  String pass});
  Future<void> setString({required String key, required String value});
  Future<void> setInt({required String key, required int value});
  Future<List<GPSSchedule>?> getUserSettings();
  String ?getString(String key);
}

class AuthorizationDataSourceImpl implements AuthorizationDataSource
{
  final SharedPreferences sharedPreferences;
  final DBProvider db;
  AuthorizationDataSourceImpl({required this.sharedPreferences,required this.db});
  @override
  Future<void> setString({required String key, required String value}) async
  {
    await sharedPreferences.setString(key, value);
  }
  @override
  Future<List<GPSSchedule>?> getUserSettings() async
  {
    return await db.getGPSSetting();
  }

  @override
  Future<void> setInt({required String key, required int value}) async
  {
    await sharedPreferences.setInt(key, value);
  }

  @override
  String ?getString(String key)
  {
    return sharedPreferences.getString(key);
  }
}