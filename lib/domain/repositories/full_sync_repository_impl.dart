import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:mobiforce_flutter/core/error/exception.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/platform/network_info.dart';
import 'package:mobiforce_flutter/data/datasources/authorization_data_sources.dart';
import 'package:mobiforce_flutter/data/datasources/authorization_remote_data_sources.dart';
import 'package:mobiforce_flutter/data/datasources/full_remote_data_sources.dart';
import 'package:mobiforce_flutter/data/datasources/task_remote_data_sources.dart';
import 'package:mobiforce_flutter/data/datasources/updates_remote_data_sources.dart';
import 'package:mobiforce_flutter/data/models/authorization_model.dart';
import 'package:mobiforce_flutter/data/models/sync_model.dart';
import 'package:mobiforce_flutter/data/models/sync_status_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/domain/entity/authorization_entity.dart';
import 'package:mobiforce_flutter/domain/entity/sync_entity.dart';
import 'package:mobiforce_flutter/domain/entity/sync_status_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/authirization_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/full_sync_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/sync_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FullSyncRepositoryImpl implements FullSyncRepository{
  final FullRemoteDataSources fullRemoteDataSources;
  final NetworkInfo networkInfo;
  final SharedPreferences sharedPreferences;
  //final AuthorizationDataSource authorizationDataSource;
  //int lastSyncTime=0;
  int fullSyncUpdateId=0;
  String domain="";
  String accessToken="";
  int fullSyncProgress=0;
  //bool fullSync=false;

  FullSyncRepositoryImpl({required this.networkInfo, required this.fullRemoteDataSources, required this.sharedPreferences})
  {
    //lastSyncTime = sharedPreferences.getInt("last_sync_time")??0;
    fullSyncUpdateId = sharedPreferences.getInt("full_sync_update_id")??0;
    fullSyncProgress = sharedPreferences.getInt("full_sync_progress")??0;
    domain=sharedPreferences.getString("domain")??"";
    accessToken=sharedPreferences.getString("access_token")??"";
    //fullSync=sharedPreferences.getBool("full_sync")??false;
  }

  @override
  Future<Either<Failure, SyncEntity>> getNext(int syncId) async {
    if(syncId!=0) {
      fullSyncUpdateId = syncId;
      await sharedPreferences.setInt("full_sync_update_id", fullSyncUpdateId);
    }
    return await _getUpdates(() => fullRemoteDataSources.getDataList(domain: domain, accessToken:accessToken, fullSyncUpdateId:fullSyncUpdateId));
    //return Right(_r);
    //throw UnimplementedError();
  }
  Future<Either<Failure,SyncModel>> _getUpdates(Future<SyncModel> Function() getData) async {

    if(await networkInfo.isConnected){
      try{
        final remoteAuth = await getData();//remoteDataSources.searchTask(query);
        /*if(remoteAuth.fullSync) {
          await sharedPreferences.setBool("full_sync", true);
          await sharedPreferences.setInt("last_sync_time", remoteAuth.lastSyncTime);
          await sharedPreferences.setInt("last_update_count", remoteAuth.lastUpdateCount);
          return Right(remoteAuth);
        }
        else
          return Right(remoteAuth);*/
        //return Right(remoteAuth);
        return Right(remoteAuth);
        //return Left(ServerFailure());
      }
      on ServerException{
        await Future.delayed(const Duration(seconds: 2), (){});
        return Left(ServerFailure());
      }
    }
    else
      return Left(ServerFailure());
    //await Future.delayed(const Duration(seconds: 1), (){});
    //fullSyncProgress+=50;
    //if(fullSyncProgress<100)
    //  return Right(SyncStatusModel(progress: fullSyncProgress,complete:false,dataLength: 0,fullSync: true));
    //else
    //  return Right(SyncStatusModel(progress: fullSyncProgress,complete:true,dataLength: 0,fullSync: true));
    /*if(fullSync){

      return Right(SyncModel(fullSync: true,lastSyncTime: 0,lastUpdateCount: 0,dataLength: 0, dataList: null));
    }
    else{
      if(await networkInfo.isConnected){
        try{
          final remoteAuth = await getData();//remoteDataSources.searchTask(query);
          if(remoteAuth.fullSync) {
            await sharedPreferences.setBool("full_sync", true);
            await sharedPreferences.setInt("last_sync_time", remoteAuth.lastSyncTime);
            await sharedPreferences.setInt("last_update_count", remoteAuth.lastUpdateCount);
            return Right(remoteAuth);
          }
          else
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

