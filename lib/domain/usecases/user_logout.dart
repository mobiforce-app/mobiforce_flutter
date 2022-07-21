import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/authorization_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/authirization_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/sync_repository.dart';
//import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
//import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:mobiforce_flutter/locator_service.dart' as di;

import '../../presentation/bloc/tasklist_bloc/blockSteam.dart';

class UserLogout extends UseCase<int, UserLogoutParams>{
  final AuthorizationRepository authRepository;
  final SyncRepository syncRepository;

  UserLogout(this.authRepository, this.syncRepository);
  Future<Either<Failure, int>> call(UserLogoutParams params) async {
    var m=di.sl<ModelImpl>();
    await m.stopUpdate();
    final FoL = await authRepository.logout();
    return FoL.fold((l) => Left(l), (r) {
      //syncRepository.realoadUSN();
      return Right(1);
    });
  }

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

class UserLogoutParams extends Equatable{
  UserLogoutParams();

  @override
  List<Object> get props => [];
}