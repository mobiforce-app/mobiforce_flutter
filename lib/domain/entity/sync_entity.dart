import 'package:mobiforce_flutter/domain/entity/sync_object_entity.dart';

class SyncEntity{
  int lastUpdateCount;
  int lastSyncTime;
  bool fullSync;
  int dataLength;
  List<SyncObjectEntity> dataList;
  SyncEntity({
    required this.lastUpdateCount,
    required this.lastSyncTime,
    required this.fullSync,
    required this.dataLength,
    required this.dataList
  });
}