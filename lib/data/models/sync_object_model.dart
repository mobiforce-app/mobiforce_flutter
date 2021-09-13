import 'package:mobiforce_flutter/domain/entity/sync_entity.dart';
import 'package:mobiforce_flutter/domain/entity/sync_object_entity.dart';

class SyncObjectModel1 extends SyncObjectEntity1
{
  SyncObjectModel1({
    required id,
    required type,
    required body,
  }) : super(
    id:id,
    type:type,
    body:body,
  );
  factory SyncObjectModel1.fromJson(Map<String, dynamic> json)
  {
    //print('jsonjson ${json[0]} ');
    return SyncObjectModel1(
        id: json["id"]??0,
        type: json["type"]??"unknown",
        body: json["body"]??null);
  }
}