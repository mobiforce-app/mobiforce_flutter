import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:mobiforce_flutter/core/error/exception.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/platform/network_info.dart';
import 'package:mobiforce_flutter/data/datasources/online_remote_data_sources.dart';
import 'package:mobiforce_flutter/data/datasources/task_remote_data_sources.dart';
import 'package:mobiforce_flutter/data/models/contractor_model.dart';
import 'package:mobiforce_flutter/data/models/equipment_model.dart';
import 'package:mobiforce_flutter/data/models/file_model.dart';
import 'package:mobiforce_flutter/data/models/task_comment_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/data/models/template_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_comment_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_life_cycle_node_entity.dart';
import 'package:mobiforce_flutter/domain/entity/tasksstatuses_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/template_repository.dart';

import '../../data/datasources/updates_remote_data_sources.dart';

class TemplateRepositoryImpl implements TemplateRepository{
  final OnlineRemoteDataSources remoteDataSources;
  //final UpdatesRemoteDataSources updatesRemoteDataSources;
  final NetworkInfo networkInfo;



  TemplateRepositoryImpl({required this.remoteDataSources,required this.networkInfo});//{required this.remoteDataSources,required this.networkInfo});



  @override
  Future<Either<Failure, List<TemplateModel>>> getAllTemplates(int page) async {
    return
     await _getTasks(()=> remoteDataSources.getAllTemplates(page));
    //return Right(_r);
    //throw UnimplementedError();
  }
  @override
  Future<Either<Failure, List<TaskModel>>> getLiveTasks(int page) async {
    if(await networkInfo.isConnected){
      try{
        final remoteTask = await remoteDataSources.getLiveTasks(page);//remoteDataSources.searchTask(query);
        return Right(remoteTask);
      }
      on ServerException{
        print("error load live tasks");
        //!!await Future.delayed(const Duration(seconds: 2), (){});
        return Left(ServerFailure());
      }
    }
    else{
      print("error load live tasks1");
      return Left(ServerFailure());
    }

  }
  @override
  Future<Either<Failure, void>>sendGeoLog({required String log}) async {
    return Right(await remoteDataSources.sendGeoLog(log:log));
  }
  @override
  Future<Either<Failure, List<ContractorModel>>> getAllContractors(String name) async {
    if(await networkInfo.isConnected){
      try{
        final remoteTask = await remoteDataSources.getAllContractors(name);//remoteDataSources.searchTask(query);
        return Right(remoteTask);
      }
      on ServerException{
        //!!await Future.delayed(const Duration(seconds: 2), (){});
        return Left(ServerFailure());
      }
    }
    else
      return Left(ServerFailure());

    //return Right(_r);
    //throw UnimplementedError();
  }
  @override
  Future<Either<Failure, List<EquipmentModel>>>getAllEquipments({String? query, int? contractor}) async
  {
    if(await networkInfo.isConnected){
      try{
        final remoteTask = await remoteDataSources.getAllEquipments(query:query, contractor:contractor);//remoteDataSources.searchTask(query);
        return Right(remoteTask);
      }
      on ServerException{
        //!!await Future.delayed(const Duration(seconds: 2), (){});
        return Left(ServerFailure());
      }
    }
    else
      return Left(ServerFailure());

    //return Right(_r);
    //throw UnimplementedError();
  }
  @override
  Future<Either<Failure, ContractorModel>> getCurrentContractor(int id) async {
    if(await networkInfo.isConnected){
      try{
          final remoteTask = await remoteDataSources.getCurrentContractor(id);//remoteDataSources.searchTask(query);
        return Right(remoteTask);
      }
      on ServerException{
        //!!await Future.delayed(const Duration(seconds: 2), (){});
        return Left(ServerFailure());
      }
    }
    else
      return Left(ServerFailure());

    //return Right(_r);
    //throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TemplateModel>> getCurrentTemplate(int id) async {
    if(await networkInfo.isConnected){
      try{
          final remoteTemplate = await remoteDataSources.getCurrentTemplate(id);//remoteDataSources.searchTask(query);
        return Right(remoteTemplate);
      }
      on ServerException{
        //!!await Future.delayed(const Duration(seconds: 2), (){});
        return Left(ServerFailure());
      }
    }
    else
      return Left(ServerFailure());

    //return Right(_r);
    //throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TaskEntity>> getCurrentTask(int id, bool saveToDB) async {
    if(await networkInfo.isConnected){
      try{
        final remoteTemplate = await remoteDataSources.getCurrentTask(id, saveToDB);//remoteDataSources.searchTask(query);
        print("=== ${remoteTemplate.toMap().toString()}");
        return Right(remoteTemplate);
      }
      on ServerException{
        //!!await Future.delayed(const Duration(seconds: 2), (){});
        return Left(ServerFailure());
      }
    }
    else
      return Left(ServerFailure());

    //return Right(_r);
    //throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TaskEntity>>createTaskOnServer(TaskEntity task) async {
    if(await networkInfo.isConnected){
      try{
        final remoteTask = await remoteDataSources.createTaskOnServer(task);//remoteDataSources.searchTask(query);
        return Right(remoteTask);
      }
      on ServerException{
        //!!await Future.delayed(const Duration(seconds: 2), (){});
        return Left(ServerFailure());
      }
    }
    else
      return Left(ServerFailure());

//await _getTasks(()=> remoteDataSources.getAllTemplates(page));
    //return Right(_r);
    //throw UnimplementedError();
  }

  Future<Either<Failure,List<TemplateModel>>> _getTasks(Future<List<TemplateModel>> Function() getTasks) async {
    if(await networkInfo.isConnected){
      try{
        final remoteTask = await getTasks();//remoteDataSources.searchTask(query);
        return Right(remoteTask);
    }
    on ServerException{
      //!!await Future.delayed(const Duration(seconds: 2), (){});
      return Left(ServerFailure());
    }
    }
    else
    return Left(ServerFailure());
  }

  @override
  Future<Either<Failure, EquipmentModel>> getCurrentEquipment(int id) async {
    if(await networkInfo.isConnected){
      try{
        final remoteTask = await remoteDataSources.getCurrentEquipment(id);//remoteDataSources.searchTask(query);
        return Right(remoteTask);
      }
      on ServerException{
        //!!await Future.delayed(const Duration(seconds: 2), (){});
        return Left(ServerFailure());
      }
    }
    else
      return Left(ServerFailure());
    // TODO: implement getCurrentEquippment
//    throw UnimplementedError();
  }

}