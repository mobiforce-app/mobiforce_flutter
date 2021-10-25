import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/authorization_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/authirization_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/sync_repository.dart';
//import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
//import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';

class Authorization extends UseCase<AuthorizationEntity, AuthorizationParams>{
  final AuthorizationRepository authRepository;
  final SyncRepository syncRepository;

  Authorization(this.authRepository, this.syncRepository);
  Future<Either<Failure, AuthorizationEntity>> call(AuthorizationParams params) async {

    final FoL = await authRepository.firstLogin(fcmToken: params.fcmToken,
          domain: params.domain,
          login: params.login,
          pass: params.pass);
    return FoL.fold((l) => Left(l), (r) {
      syncRepository.realoadUSN();
      return Right(r);
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

class AuthorizationParams extends Equatable{
  final String login;
  final String pass;
  final String domain;
  final String? fcmToken;
  AuthorizationParams({required this.login,required this.pass,required this.domain,this.fcmToken});

  @override
  List<Object> get props => [login,pass,domain];
}