import 'dart:async';

import 'package:mobiforce_flutter/domain/usecases/full_sync_from_server.dart';
import 'package:mobiforce_flutter/domain/usecases/sync_from_server.dart';
import 'package:mobiforce_flutter/presentation/bloc/sync_bloc/sync_event.dart';
class FullSyncStatus
{
  String? syncNameStr;
  double progress;
  //int max;
  bool complete;
  //int lastUpdateCount;
  //int lastSyncTime;
  //bool isFirstSync;
  FullSyncStatus({required this.progress,required this.complete,required this.syncNameStr});
}
abstract class FullSync{
  Stream<dynamic> get counterUpdates;
  void startUpdate();
}
class FullSyncImpl implements FullSync{
  int _counter = 0;
  final Map<String,String> objectsTypeToName={
    "taskfield":"Дополнительные поля",
    "taskstatus":"Статусы",
    "resolution":"Причины завершения",
    "tasklifecycle":"Жизненные циклы",
    "task":"Задачи",
    "comments":"Комментарии"};
  final FullSyncFromServer fullSyncFromServer;
  FullSyncImpl({required this.fullSyncFromServer});

  FullSyncStatus s = FullSyncStatus(progress: 0,complete:false,syncNameStr:"");
  //var controller = new StreamController<String>();
  StreamController _streamController = new StreamController<FullSyncStatus>();

  Stream<dynamic> get counterUpdates => _streamController.stream;

  Future<void> startUpdate() async {
    bool complete=true;
    int syncId=0;
    while(complete) {
      final faiureOrLoading = await fullSyncFromServer(FullSyncParams(syncId));
      faiureOrLoading.fold((failure)=> {
        print ("*x")
      }, (sync) {
        syncId=sync.progress;
        print("progress ${sync.progress} ${sync.dataLength}");
        // open full sync page
        double progress=100.0;
        if(sync.dataLength>0)
          progress=(10000.0*sync.progress/sync.dataLength).roundToDouble()/100;
        print("fullSync progress ${sync.progress}");
        if(sync.complete){
          complete=false;
          _streamController.add(FullSyncStatus(complete: true, progress: progress,syncNameStr:objectsTypeToName[sync.objectType]));
        }
        else{
          _streamController.add(FullSyncStatus(complete: false, progress: progress,syncNameStr:objectsTypeToName[sync.objectType]));
        }
        //_streamController.add(FullSyncStatus(max:0,progress: 0,complete: true));
        //if(sync.fullSync)
        //{
        //  _streamController.add(FullSyncStatus(max:0,progress: 0,complete: true));
        //}
        //print("**");
      });
      /*Future.delayed(Duration(seconds: 10),() {
        _counter++;
        s.progress++;
        _streamController.add(s);
      });*/
    }
  }

  //getUpdates();
  //<Future>void getTasks
}