import 'package:dartz/dartz.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/data/datasources/authorization_data_sources.dart';
import 'package:mobiforce_flutter/domain/entity/authorization_entity.dart';

import '../entity/user_setting_entity.dart';

abstract class AuthorizationRepository{
  Future<Either<Failure, AuthorizationEntity>>firstLogin({String domain, String login, String pass, String? fcmToken});
  Future<void> saveAuthorization({required String token, required String domain, required int selfId, required String selfName});
  String?getAuthorization();
  Future<UserSettingEntity> getUserSettings();
}