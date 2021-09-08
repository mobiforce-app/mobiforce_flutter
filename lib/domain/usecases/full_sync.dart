import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/authorization_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/authirization_repository.dart';
//import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
//import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';

class AuthorizationManager {
  final AuthorizationRepository authRepository;
  AuthorizationManager(this.authRepository);
  bool check(){
    //return false;
    if(authRepository.getAuthorization()==null)
      return false;
    else
      return true;
  }
  Future<void> autorize(String token) async{
    //await authRepository.saveAuthorization(token);
    //return true;
  }

}
