
import 'package:mobiforce_flutter/domain/entity/authorization_entity.dart';

class AuthorizationModel extends AuthorizationEntity
{
  AuthorizationModel({
    required token
  }) : super(
      token:token
  );
  factory AuthorizationModel.fromJson(Map<String, dynamic> json)
  {
    //print('jsonjson ${json[0]} ');
    return AuthorizationModel(token:json["hash"].toString());
  }
}