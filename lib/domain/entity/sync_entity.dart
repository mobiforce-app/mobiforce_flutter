import 'package:mobiforce_flutter/domain/entity/sync_object_entity.dart';

class SyncEntity{
  //int lastUpdateCount;
  int lastSyncTime;
  bool fullSync;
  int dataLength;
  int dataProgress;
  List<dynamic> dataList;
  String objectType;
  int lastUpdateCount;
  SyncEntity({
    required this.lastUpdateCount,
    required this.lastSyncTime,
    required this.fullSync,
    required this.dataLength,
    required this.dataList,
    required this.dataProgress,
    required this.objectType
  });
}