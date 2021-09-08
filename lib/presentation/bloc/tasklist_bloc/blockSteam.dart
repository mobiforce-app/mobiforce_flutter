import 'dart:async';

import 'package:mobiforce_flutter/domain/usecases/sync_from_server.dart';
class SyncStatus
{
  int progress;
  int max;
  //int lastUpdateCount;
  //int lastSyncTime;
  bool isFirstSync;
  SyncStatus({required this.max,required this.progress,required this.isFirstSync});
}
abstract class Model{
  Stream<dynamic> get counterUpdates;
  void startUpdate();
  //Future<Either<Failure, AuthorizationEntity>>firstLogin({String domain, String login, String pass});
  //Future<void> saveAuthorization(String token);
  //String?getAuthorization();
}
class ModelImpl implements Model{
  int _counter = 0;
  final SyncFromServer syncFromServer;
  ModelImpl({required this.syncFromServer});

  SyncStatus s = SyncStatus(max: 0,progress: 0,isFirstSync:false);
  //var controller = new StreamController<String>();
  StreamController _streamController = new StreamController<SyncStatus>();

  Stream<dynamic> get counterUpdates => _streamController.stream;

  Future<void> startUpdate() async {

    final faiureOrLoading = await syncFromServer(ListSyncParams(lastSyncTime: 0, lastUpdateCount: 0,));
    faiureOrLoading.fold((failure)=> {
      print ("*")
    }, (sync) {

      // open full sync page
      print("fullSync ${sync.fullSync}");
      if(sync.fullSync)
      {
        _streamController.add(SyncStatus(max:0,progress: 0,isFirstSync: true));
      }
      //print("**");
    });
    /*Future.delayed(Duration(seconds: 10),() {
        _counter++;
        s.progress++;
        _streamController.add(s);
      });*/
  }
  //getUpdates();
  //<Future>void getTasks
}