import 'package:mobiforce_flutter/data/models/sync_object_model.dart';
import 'package:mobiforce_flutter/domain/entity/sync_entity.dart';
import 'package:mobiforce_flutter/domain/entity/sync_status_entity.dart';

class SyncStatusModel extends SyncStatusEntity
{
  SyncStatusModel({
    required complete,
    required progress,
    required dataLength,
    required fullSync,
  }) : super(
      complete:complete,
      fullSync:fullSync,
      progress:progress,
      dataLength:dataLength,
  );
  /*factory SyncModel.fromJson(Map<String, dynamic> json)
  {
    print('json ${json.toString()} ');
    return SyncModel(
        lastUpdateCount: 0,//int.parse(json["lastUpdateCount"]??0),
        lastSyncTime: 0,//int.parse(json["lastSyncTime"]??0),
        dataLength: 0, //int.parse(json["dataLength"]??0),
        fullSync: json["fullSync"]??false,
        dataList:(json['dataList'] as List).map((task)=> SyncObjectModel.fromJson(task)).toList());
  }*/
}