import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:mobiforce_flutter/core/error/exception.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/platform/network_info.dart';
import 'package:mobiforce_flutter/data/datasources/task_remote_data_sources.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository{
  final TaskRemoteDataSources remoteDataSources;
  final NetworkInfo networkInfo;

  TaskRepositoryImpl({required this.remoteDataSources,required this.networkInfo});

  @override
  Future<Either<Failure, bool>>setTaskFieldSelectionValue({required TasksFieldsModel taskField}) async {
    bool res = await remoteDataSources.setTaskFieldSelectionValue(taskField:taskField);
    if(res)
      return Right(true);
    else
      return Left(ServerFailure());
  }
  @override
  Future<Either<Failure, TaskEntity>>setTaskStatus({required int status,required int task,int? resolution}) async {
    print("resolution1 $resolution");
    return Right(await remoteDataSources.setTaskStatus(status:status, task:task, resolution:resolution));
  }
  @override
  Future<Either<Failure, List<TaskStatusEntity>>>getTaskStatusGraph(int? id) async {
    return Right(await remoteDataSources.getTaskStatusGraph(id));
    //return Right(_r);
    //throw UnimplementedError();
  }
  Future<Either<Failure, List<TaskEntity>>> searchTask(String query) async {
   return await _getTasks(()=> remoteDataSources.searchTask(query));
    //return Right(_r);
    //throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getAllTasks(int page) async {
   return await _getTasks(()=> remoteDataSources.getAllTask(page));
    //return Right(_r);
    //throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TaskEntity>> getTask(int id) async {
   return Right(await remoteDataSources.getTask(id));
   // return Right(_r);
    //throw UnimplementedError();
    //return ;
  }

  Future<Either<Failure,List<TaskModel>>> _getTasks(Future<List<TaskModel>> Function() getTasks) async {
    if(await networkInfo.isConnected){
      try{
        final remoteTask = await getTasks();//remoteDataSources.searchTask(query);
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