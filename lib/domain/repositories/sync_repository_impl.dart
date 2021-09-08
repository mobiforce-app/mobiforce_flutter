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
import 'package:mobiforce_flutter/data/models/sync_model.dart';
import 'package:mobiforce_flutter/data/models/sync_status_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/domain/entity/authorization_entity.dart';
import 'package:mobiforce_flutter/domain/entity/sync_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/authirization_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/sync_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncRepositoryImpl implements SyncRepository{
  final UpdatesRemoteDataSources updatesRemoteDataSources;
  final NetworkInfo networkInfo;
  final SharedPreferences sharedPreferences;
  //final AuthorizationDataSource authorizationDataSource;
  int lastSyncTime=0;
  int lastUpdateCount=0;
  String domain="";
  String accessToken="";
  bool fullSync=false;

  SyncRepositoryImpl({required this.networkInfo, required this.updatesRemoteDataSources, required this.sharedPreferences})
  {
    lastSyncTime = sharedPreferences.getInt("last_sync_time")??0;
    lastUpdateCount = sharedPreferences.getInt("last_update_count")??0;
    domain=sharedPreferences.getString("domain")??"";
    accessToken=sharedPreferences.getString("access_token")??"";
    fullSync=sharedPreferences.getBool("full_sync")??false;
  }

  @override
  Future<Either<Failure, SyncStatusModel>> getUpdates() async {
    return await _getUpdates(()=> updatesRemoteDataSources.getDataList(domain: domain, accessToken:accessToken, lastSyncTime:lastSyncTime, lastUpdateCount:lastUpdateCount));
    //return Right(_r);
    //throw UnimplementedError();
  }
  Future<Either<Failure,SyncStatusModel>> _getUpdates(Future<SyncModel> Function() getData) async {
    if(fullSync){
      return Right(SyncStatusModel(fullSync: true,progress: 0,complete: false,dataLength: 0));
    }
    else{
      if(await networkInfo.isConnected){
        try{
          final remoteAuth = await getData();//remoteDataSources.searchTask(query);
          if(remoteAuth.fullSync) {
            await sharedPreferences.setBool("full_sync", true);
            await sharedPreferences.setInt("last_sync_time", remoteAuth.lastSyncTime);
            await sharedPreferences.setInt("last_update_count", remoteAuth.lastUpdateCount);
            return Right(SyncStatusModel(fullSync: true,progress: 0,complete: false,dataLength: 0));
          }
          else
            return Right(SyncStatusModel(fullSync: false,progress: 0,complete: false,dataLength: 0));
        }
        on ServerException{
          await Future.delayed(const Duration(seconds: 2), (){});
          return Left(ServerFailure());
        }
      }
      else
        return Left(ServerFailure());
    }
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