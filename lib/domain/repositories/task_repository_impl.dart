import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:mobiforce_flutter/core/error/exception.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/platform/network_info.dart';
import 'package:mobiforce_flutter/data/datasources/task_remote_data_sources.dart';
import 'package:mobiforce_flutter/data/models/file_model.dart';
import 'package:mobiforce_flutter/data/models/task_comment_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/domain/entity/phone_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_comment_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_life_cycle_node_entity.dart';
import 'package:mobiforce_flutter/domain/entity/tasksstatuses_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';

import '../entity/template_entity.dart';
import '../entity/user_setting_entity.dart';

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
  Future<Either<Failure, TaskEntity>>setTaskStatus({
    int? id,
    required int status,
    required int task,
    int? resolution,
    required String comment,
    required DateTime createdTime,
    required DateTime manualTime,
    required bool timeChanging,
    required bool dateChanging,
    required bool commentChanging,
    required bool commentRequired,
  }) async {
    print("resolution1 $resolution");
    return Right(await remoteDataSources.setTaskStatus(
        id:id,
        status:status,
        task:task,
        resolution:resolution,
        comment:comment,
        createdTime:createdTime,
        manualTime:manualTime,
        timeChanging:timeChanging,
        dateChanging:dateChanging,
        commentChanging:commentChanging,
        commentRequired:commentRequired,

    ));
  }
  @override
  Future<Either<Failure, List<TaskLifeCycleNodeEntity>>>getTaskStatusGraph(int? id, int? lifecycle) async {
    return Right(await remoteDataSources.getTaskStatusGraph(id, lifecycle));
    //return Right(_r);
    //throw UnimplementedError();
  }
  @override
  Future<Either<Failure, UserSettingEntity>>getUserSetting() async {
    return Right(await remoteDataSources.getUserSetting());
    //return Right(_r);
    //throw UnimplementedError();
  }
  @override
  Future<Either<Failure, FileModel>>addTaskFieldPicture({required int taskFieldId, required int pictureId}) async {
    print("picture id= $pictureId");
    return Right(await remoteDataSources.addPictureTaskField(taskFieldId:taskFieldId,pictureId:pictureId));
    //return Right(_r);
    //throw UnimplementedError();
  }
   @override
   Future<Either<Failure, PhoneEntity>>addNewPhone({required String name}) async {
    //print("picture id= $pictureId");
    return Right(await remoteDataSources.addNewPhone(name:name));
    //return Right(_r);
    //throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<int>>> getTasksMounthCounter({required DateTime from, required DateTime till}) async
  {
    print("additional ****");
    return  Right(await remoteDataSources.getTasksMounthCounter(from,till));
  }

  @override
  void setFilter({DateTime? dateFrom, DateTime? dateTill})
  {
    print("filter");
    remoteDataSources.setFilter(dateFrom:dateFrom,dateTill:dateTill);
    //print("additional ****");
    ///return  Right(await remoteDataSources.getTasksMounthCounter(from,till));
  }

  @override
  Future<Either<Failure, FileModel>>deleteTaskFieldPicture({required int taskFieldId, required int pictureId}) async {
    print("picture id= $pictureId");
    return Right(await remoteDataSources.deletePictureTaskField(taskFieldId:taskFieldId,pictureId:pictureId));
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
  Future<Either<Failure, List<TemplateEntity>>> getAllTemplates(int page) async {
   return  Right(await remoteDataSources.getAllTemplates(page));
    //return Right(_r);
    //throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TaskEntity>>saveNewTask({required TaskEntity task}) async {
    return Right(await remoteDataSources.saveNewTask(task:task));
  }

  @override
  Future<Either<Failure, List<TaskCommentEntity>>>getAllTaskComments(int task, int page) async {

    return Right(await remoteDataSources.getCommentList(task:task,page:page));
    //return Right([TaskCommentModel(id: 0, usn: 0, task: task, createdTime: 0, dirty: 0, serverId: 0)]);
//  Future<Either<Failure, List<TaskEntity>>> getAllTasks(int page) async {
   //return await _getTasks(()=> remoteDataSources.getAllTask(page));
    //return Right(_r);
    //throw UnimplementedError();
  }
  @override
  Future<Either<Failure, void>>setTaskCommentsRead(List<TaskCommentEntity?> comments) async {

    return Right(await remoteDataSources.setTaskCommentsRead(comments:comments));
    //return Right([TaskCommentModel(id: 0, usn: 0, task: task, createdTime: 0, dirty: 0, serverId: 0)]);
//  Future<Either<Failure, List<TaskEntity>>> getAllTasks(int page) async {
   //return await _getTasks(()=> remoteDataSources.getAllTask(page));
    //return Right(_r);
    //throw UnimplementedError();
  }
  @override
  Future<Either<Failure, TaskCommentEntity>>addTaskComment( {required TaskCommentModel comment}) async {

    comment = await remoteDataSources.addTaskComment(comment:comment);
    return Right(comment);
    //return Right([TaskCommentModel(id: 0, usn: 0, task: task, createdTime: 0, dirty: 0, serverId: 0)]);
//  Future<Either<Failure, List<TaskEntity>>> getAllTasks(int page) async {
   //return await _getTasks(()=> remoteDataSources.getAllTask(page));
    //return Right(_r);
    //throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TaskEntity>> getTaskByExternalId(int externalId) async {
   return Right(await remoteDataSources.getTaskByExternalId(externalId));
   // return Right(_r);
    //throw UnimplementedError();
    //return ;
  }
  @override
  Future<Either<Failure, TaskEntity>> getTask(int id) async {
   return Right(await remoteDataSources.getTask(id));
   // return Right(_r);
    //throw UnimplementedError();
    //return ;
  }

  Future<Either<Failure,List<TaskModel>>> _getTasks(Future<List<TaskModel>> Function() getTasks) async {
    //if(await networkInfo.isConnected){
    //  try{
        final remoteTask = await getTasks();//remoteDataSources.searchTask(query);
        return Right(remoteTask);
      //}
      //on ServerException{
      //  //!!await Future.delayed(const Duration(seconds: 2), (){});
      //  return Left(ServerFailure());
      //}
    //}
    //else
      //return Left(ServerFailure());
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