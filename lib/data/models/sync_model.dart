import 'package:mobiforce_flutter/data/models/sync_object_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/domain/entity/sync_entity.dart';

class SyncModel extends SyncEntity
{
  SyncModel({
    required lastUpdateCount,
    required lastSyncTime,
    required fullSync,
    required dataProgress,
    required dataLength,
    required dataList,
    required objectType
  }) : super(
      lastUpdateCount:lastUpdateCount,
      lastSyncTime:lastSyncTime,
      fullSync:fullSync,
      dataLength:dataLength,
      dataList:dataList,
      dataProgress:dataProgress,
      objectType:objectType
  );
  factory SyncModel.fromJson(Map<String, dynamic> json,List<dynamic> Function(dynamic) mapObjects)
  {
    dynamic d=TaskModel;
    print('json ${json.toString()}');
    return SyncModel(
        lastUpdateCount: json["lastUpdateCount"]??0,//.map((obj){print("map ${obj}");return{"task":1};}),//int.parse(json["lastUpdateCount"]??0),
        lastSyncTime: json["lastSyncTime"]??0,
        dataLength: json["dataLength"]??0,
        dataProgress: 0, //int.parse(json["dataLength"]??0),
        objectType: json["objectType"]??"",
        fullSync: json["fullSync"]??false,
        dataList:mapObjects(json['dataList']));//(json['dataList'] as List).map((obj)=>(d).fromJson(obj)).toList());
  }
}