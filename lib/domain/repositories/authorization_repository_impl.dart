import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:mobiforce_flutter/core/error/exception.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/platform/network_info.dart';
import 'package:mobiforce_flutter/data/datasources/authorization_data_sources.dart';
import 'package:mobiforce_flutter/data/datasources/authorization_remote_data_sources.dart';
import 'package:mobiforce_flutter/data/datasources/task_remote_data_sources.dart';
import 'package:mobiforce_flutter/data/models/authorization_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/domain/entity/authorization_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/authirization_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';

import '../entity/user_setting_entity.dart';

class AuthorizationRepositoryImpl implements AuthorizationRepository{
  final AuthorizationRemoteDataSources remoteDataSources;
  final NetworkInfo networkInfo;
  final AuthorizationDataSource authorizationDataSource;

  AuthorizationRepositoryImpl({required this.remoteDataSources,required this.networkInfo, required this.authorizationDataSource});

  @override
  Future<Either<Failure, AuthorizationEntity>> firstLogin({String domain = "", String login = "", String pass = "", String? fcmToken}) async {
   return await _getAuthrisationInfo(()=> remoteDataSources.firstLogin(domain: domain, login:login, pass:pass, fcmToken: fcmToken));
    //return Right(_r);
    //throw UnimplementedError();
  }

  @override
  Future <void> saveAuthorization({required String token, required String domain, required int selfId, required String selfName}) async {
   //return await _getAuthrisationInfo(()=> remoteDataSources.firstLogin(domain: domain, login:login, pass:pass));
    //return Right(_r);
    //throw UnimplementedError();
    print("saveAuthorization $domain");
    await authorizationDataSource.setInt(key: "self_id", value: selfId);
    await authorizationDataSource.setString(key: "self_name", value: selfName);
    await authorizationDataSource.setString(key: "access_token", value: token);
    await authorizationDataSource.setString(key: "access_token", value: token);
    await authorizationDataSource.setString(key: "domain", value: domain);
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
  @override
  Future<UserSettingEntity> getUserSettings() async {
   //return await _getAuthrisationInfo(()=> remoteDataSources.firstLogin(domain: domain, login:login, pass:pass));
    //return Right(_r);
    //throw UnimplementedError();
    //await authorizationDataSource.setString(key: "access_token", value: token);
    return await authorizationDataSource.getUserSettings();
  }


 /* @override
  Future<Either<Failure, List<TaskEntity>>> getAllTasks(int page) async {
   return await _getTasks(()=> remoteDataSources.getAllTask(page));
    //return Right(_r);
    //throw UnimplementedError();
  }
*/
  Future<Either<Failure,AuthorizationModel>> _getAuthrisationInfo(Future<AuthorizationModel> Function() getAuthrisationInfo) async {
    if(await networkInfo.isConnected){
      try{
        final remoteAuth = await getAuthrisationInfo();//remoteDataSources.searchTask(query);
        await saveAuthorization(token:remoteAuth.token,domain:remoteAuth.domain, selfId: remoteAuth.id, selfName: remoteAuth.name);
        return Right(remoteAuth);
      }
      on ServerException{
        //!!await Future.delayed(const Duration(seconds: 2), (){});
        return Left(ServerFailure());
      }
    }
    else
      return Left(ServerFailure());
  }
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