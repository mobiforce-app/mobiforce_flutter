import 'package:mobiforce_flutter/domain/entity/sync_entity.dart';
import 'package:mobiforce_flutter/domain/entity/sync_object_entity.dart';

class SyncObjectModel extends SyncObjectEntity
{
  SyncObjectModel({
    required id,
    required type,
    required body,
  }) : super(
    id:id,
    type:type,
    body:body,
  );
  factory SyncObjectModel.fromJson(Map<String, dynamic> json)
  {
    //print('jsonjson ${json[0]} ');
    return SyncObjectModel(
        id: json["id"]??0,
        type: json["type"]??"unknown",
        body: json["body"]??null);
  }
}