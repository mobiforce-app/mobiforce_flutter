import 'package:dartz/dartz.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/domain/entity/authorization_entity.dart';

abstract class AuthorizationRepository{
  Future<Either<Failure, AuthorizationEntity>>firstLogin({String domain, String login, String pass});

}