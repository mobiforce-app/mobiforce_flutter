import 'package:mobiforce_flutter/domain/entity/sync_object_entity.dart';

class SyncStatusEntity{
  //int lastUpdateCount;
  //int lastSyncTime;
  bool complete;
  bool fullSync;
  int progress;
  int dataLength;
  //List<SyncObjectEntity> dataList;
  SyncStatusEntity({
    required this.fullSync,
    required this.complete,
    required this.progress,
    required this.dataLength,
  });
}