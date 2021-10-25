
import 'package:mobiforce_flutter/domain/entity/authorization_entity.dart';

class AuthorizationModel extends AuthorizationEntity
{
  AuthorizationModel({
    required id,
    required name,
    required token,
    required domain
  }) : super(
      token:token, domain:domain, id:id, name:name
  );
  factory AuthorizationModel.fromJson(Map<String, dynamic> json)
  {
    //print('jsonjson ${json[0]} ');
    return AuthorizationModel(
        id:int.tryParse(json["id"]??"0"),
        name:json["name"].toString(),
        token:json["hash"].toString(),
        domain:json["domain"].toString()
    );
  }
}