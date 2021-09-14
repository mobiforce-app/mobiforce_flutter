import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:mobiforce_flutter/core/error/exception.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/platform/network_info.dart';
import 'package:mobiforce_flutter/data/datasources/authorization_data_sources.dart';
import 'package:mobiforce_flutter/data/datasources/authorization_remote_data_sources.dart';
import 'package:mobiforce_flutter/data/datasources/task_remote_data_sources.dart';
import 'package:mobiforce_flutter/data/datasources/updates_remote_data_sources.dart';
import 'package:mobiforce_flutter/data/models/authorization_model.dart';
import 'package:mobiforce_flutter/data/models/resolution_model.dart';
import 'package:mobiforce_flutter/data/models/sync_model.dart';
import 'package:mobiforce_flutter/data/models/sync_status_model.dart';
import 'package:mobiforce_flutter/data/models/task_life_cycle_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/taskstatus_model.dart';
import 'package:mobiforce_flutter/domain/entity/authorization_entity.dart';
import 'package:mobiforce_flutter/domain/entity/sync_entity.dart';
import 'package:mobiforce_flutter/domain/entity/sync_status_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/authirization_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/sync_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncRepositoryImpl implements SyncRepository{
  final UpdatesRemoteDataSources updatesRemoteDataSources;
  final NetworkInfo networkInfo;
  final SharedPreferences sharedPreferences;
  final List<String> objectsType=["taskstatus","tasklifecycle","task","resolution"];
  final List<int> objectsTypeLastUpdateId=[];
  int syncObjectsTypeId=0;

  //final AuthorizationDataSource authorizationDataSource;
  int lastSyncTime=0;
///  int lastUpdateCount=0;
  String domain="";
  String accessToken="";
  bool fullSync=false;

  SyncRepositoryImpl({required this.networkInfo, required this.updatesRemoteDataSources, required this.sharedPreferences})
  {
    lastSyncTime = sharedPreferences.getInt("last_sync_time")??0;
    //lastUpdateCount = sharedPreferences.getInt("last_update_count")??0;
    for(int i=0; i<objectsType.length;i++ ){
      objectsTypeLastUpdateId.add(sharedPreferences.getInt("last_update_count_${objectsType[i]}")??0);
    }
    domain=sharedPreferences.getString("domain")??"";
    accessToken=sharedPreferences.getString("access_token")??"";
    fullSync=sharedPreferences.getBool("full_sync")??false;
  }
  @override
  Future<bool>commit() async {
    await sharedPreferences.setInt("last_update_count_${objectsType[syncObjectsTypeId]}", objectsTypeLastUpdateId[syncObjectsTypeId]);
    return true;
  }
  @override
  Future<bool>setComplete() async {
    print("complete fullSyncObjectsTypeId = $syncObjectsTypeId");
    syncObjectsTypeId++;
    //fullSyncUpdateId=0;
    //await sharedPreferences.setInt("full_sync_objects_type_id", fullSyncObjectsTypeId);
    //await sharedPreferences.setInt("full_sync_update_id", fullSyncUpdateId);
    if(syncObjectsTypeId>=objectsType.length) {
      syncObjectsTypeId=0;
      return true;
    }
    else
      return false;

  }

  @override
  bool isFullSyncStarted()
  {
    return sharedPreferences.getBool("full_sync")??false;
  }
  @override
  Future<Either<Failure, SyncModel>> getUpdates() async {

    List<dynamic> mapObject(json) {
      //dynamic t=TaskModel;
      if(objectsType[syncObjectsTypeId]=="task") {
        print ("type = task");
        return ((json as List).map((obj) => TaskModel.fromJson(obj)).toList());
      }
      if(objectsType[syncObjectsTypeId]=="tasklifecycle") {
        print ("type = task");
        return ((json as List).map((obj) => TaskLifeCycleModel.fromJson(obj)).toList());
      }
      if(objectsType[syncObjectsTypeId]=="taskstatus") {
        print ("type = taskstatus");
        return ((json as List).map((obj) => TaskStatusModel.fromJson(obj)).toList());
      }
      if(objectsType[syncObjectsTypeId]=="resolution"){
        print ("type = resolution");
        return ((json as List).map((obj) => ResolutionModel.fromJson(obj)).toList());
      }

      return ((json as List).map((obj) => TaskModel.fromJson(obj)).toList());
    }

    return await _getUpdates(()=> updatesRemoteDataSources.getDataList(
        domain: domain,
        accessToken:accessToken,
        objectType:objectsType[syncObjectsTypeId],
        lastSyncTime:lastSyncTime,
        lastUpdateCount:objectsTypeLastUpdateId[syncObjectsTypeId],
        mapObjects: mapObject
    ));
    //return Right(_r);
    //throw UnimplementedError();
  }
  Future<Either<Failure,SyncModel>> _getUpdates(Future<SyncModel> Function() getData) async {
      if(await networkInfo.isConnected){
        try{
          final remoteData = await getData();//remoteDataSources.searchTask(query);
          //if(remoteAuth.fullSync) {
            // await sharedPreferences.setBool("full_sync", true);
            // await sharedPreferences.setInt("last_sync_time", remoteAuth.lastSyncTime);
            // await sharedPreferences.setInt("last_update_count", remoteAuth.lastUpdateCount);
            // await sharedPreferences.setInt("full_sync_update_id", 0);
            // await sharedPreferences.setInt("full_sync_objects_type_id", 0);
          if(remoteData.dataList.isNotEmpty){
            print("new fullSyncUpdateId = ${remoteData.dataList.last.usn}");
            objectsTypeLastUpdateId[syncObjectsTypeId]=remoteData.dataList.last.usn;
            //fullSyncUpdateId=remoteData.dataList.last.usn;
            //syncDataProgress=syncDataProgress+remoteData.dataList.length;
          }
          print("remoteAuth = ${remoteData.toString()}");
            return Right(remoteData);//SyncStatusModel(syncPhase: SyncPhase.fullSyncStart,progress: 0,complete: false,dataLength: 0));
          //}
          //else
          //  return Right(remoteAuth);//SyncStatusModel(syncPhase: SyncPhase.normalfullSyncComplete,progress: 0,complete: false,dataLength: 0));
        }
        on ServerException{
          await Future.delayed(const Duration(seconds: 2), (){});
          return Left(ServerFailure());
        }
      }
      else
        return Left(ServerFailure());
    }
 /* @override
  Future <void> saveAuthorization(String token) async {
   //return await _getAuthrisationInfo(()=> remoteDataSources.firstLogin(domain: domain, login:login, pass:pass));
    //return Right(_r);
    //throw UnimplementedError();
    await authorizationDataSource.setString(key: "access_token", value: token);
    await authorizationDataSource.setInt(key: "start_sync_position", value: -1);
    await authorizationDataSource.setInt(key: "start_sync_length", value: -1);
    await authorizationDataSource.setInt(key: "last_update_count", value: 0);
    await authorizationDataSource.setInt(key: "last_sync_time", value: 0);

  }
  @override
  String?getAuthorization() {
   //return await _getAuthrisationInfo(()=> remoteDataSources.firstLogin(domain: domain, login:login, pass:pass));
    //return Right(_r);
    //throw UnimplementedError();
    //await authorizationDataSource.setString(key: "access_token", value: token);
    return authorizationDataSource.getString("access_token");
  }
*/

 /* @override
  Future<Either<Failure, List<TaskEntity>>> getAllTasks(int page) async {
   return await _getTasks(()=> remoteDataSources.getAllTask(page));
    //return Right(_r);
    //throw UnimplementedError();
  }
*/
  /*
  Future<Either<Failure,AuthorizationModel>> _getAuthrisationInfo(Future<AuthorizationModel> Function() getAuthrisationInfo) async {
    if(await networkInfo.isConnected){
      try{
        final remoteAuth = await getAuthrisationInfo();//remoteDataSources.searchTask(query);
        await saveAuthorization(remoteAuth.token);
        return Right(remoteAuth);
      }
      on ServerException{
        await Future.delayed(const Duration(seconds: 2), (){});
        return Left(ServerFailure());
      }
    }
    else
      return Left(ServerFailure());
  }*/
  /*Future<Either<Failure,<List<TaskEntity>>> _getTasks(Future<List<TaskEntity>> Function() getTasks) async  {

  }*/
/*
  Future<Either<Failure,<List<TaskEntity>>> _getTasks(Future<List<TaskEntity>> Function() getTasks) async  {
    if(await networkInfo.isConnected){
      try{
        final remoteTask = await getTasks();//remoteDataSources.searchTask(query);
        return Right(remoteTask);
      } on ServerFailure{
        return Left(ServerFailure());
      }
    }
    else
      return Left(ServerFailure());
 }

 */
}