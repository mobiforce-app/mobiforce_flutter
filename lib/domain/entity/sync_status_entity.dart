import 'package:mobiforce_flutter/domain/entity/sync_object_entity.dart';
enum SyncPhase{
  normal,
  fullSyncStart,
  fullSyncResume,
  normalfullSyncComplete,
  normalSyncComplete
}

class SyncStatusEntity{
  //int lastUpdateCount;
  //int lastSyncTime;
  bool complete;
  SyncPhase syncPhase;
  int progress;
  int dataLength;
  bool sendToken;
  //List<SyncObjectEntity> dataList;
  SyncStatusEntity({
    required this.syncPhase,
    required this.complete,
    required this.progress,
    required this.dataLength,
    required this.sendToken,
  });
}