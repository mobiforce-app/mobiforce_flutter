import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:mobiforce_flutter/core/error/exception.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/platform/network_info.dart';
import 'package:mobiforce_flutter/data/datasources/authorization_remote_data_sources.dart';
import 'package:mobiforce_flutter/data/datasources/task_remote_data_sources.dart';
import 'package:mobiforce_flutter/data/models/authorization_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/domain/entity/authorization_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/authirization_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';

class AuthorizationRepositoryImpl implements AuthorizationRepository{
  final AuthorizationRemoteDataSources remoteDataSources;
  final NetworkInfo networkInfo;

  AuthorizationRepositoryImpl({required this.remoteDataSources,required this.networkInfo});

  @override
  Future<Either<Failure, AuthorizationEntity>> firstLogin({String domain = "", String login = "", String pass = ""}) async {
   return await _getAuthrisationInfo(()=> remoteDataSources.firstLogin(domain: domain, login:login, pass:pass));
    //return Right(_r);
    //throw UnimplementedError();
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
        final remoteTask = await getAuthrisationInfo();//remoteDataSources.searchTask(query);
        return Right(remoteTask);
      }
      on ServerException{
        await Future.delayed(const Duration(seconds: 2), (){});
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