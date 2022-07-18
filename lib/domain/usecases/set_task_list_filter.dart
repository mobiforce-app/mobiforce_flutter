import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/authorization_entity.dart';
import 'package:mobiforce_flutter/domain/entity/user_setting_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/authirization_repository.dart';
//import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
//import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
as bg;

import '../entity/employee_entity.dart';
import '../repositories/task_repository.dart';

class SetTaskListFilter {
  final TaskRepository taskRepository;
  SetTaskListFilter(this.taskRepository);
  void call({DateTime? dateFrom, DateTime? dateTill}){
      taskRepository.setFilter(dateFrom:dateFrom,dateTill:dateTill);
  }
 // Future<void> autorize({required String token, required String domain}) async{
    //await authRepository.saveAuthorization(token:token, domain:domain);
    //return true;
 // }
  //Future<Either<Failure, AuthorizationEntity>> call(AuthorizationParams params) async => await authRepository.firstLogin(domain:params.domain,login:params.login,pass:params.pass);

  /*Future<Either<Failure, List<TaskEntity>>> getAllTasks(int page) async {
    return await _getTasks(()=> remoteDataSources.getAllTask(page));
    //return Right(_r);
    //throw UnimplementedError();
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
  }*/
}
