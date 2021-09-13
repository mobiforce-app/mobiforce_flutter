import 'dart:async';

import 'package:mobiforce_flutter/domain/entity/sync_status_entity.dart';
import 'package:mobiforce_flutter/domain/usecases/sync_from_server.dart';
class SyncStatus
{
  //int progress;
  //int max;
  //int lastUpdateCount;
  //int lastSyncTime;
  SyncPhase syncPhase;
  SyncStatus({required this.syncPhase});
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

  SyncStatus s = SyncStatus(syncPhase:SyncPhase.normal);
  //var controller = new StreamController<String>();
  StreamController _streamController = new StreamController<SyncStatus>();

  Stream<dynamic> get counterUpdates => _streamController.stream;

  Future<void> startUpdate() async {

    while(true)
    {

      final faiureOrLoading = await syncFromServer(ListSyncParams(lastSyncTime: 0, lastUpdateCount: 0,));
      bool complete=faiureOrLoading.fold((failure) {
        print ("*");
        return false;
      }, (sync) {

        // open full sync page
        print("fullSync ${sync.syncPhase}");
        if(sync.syncPhase != SyncPhase.normal)
        {
          _streamController.add(SyncStatus(syncPhase:sync.syncPhase));
          return true;
        }
        return sync.complete;
        //print("**");
      });
      if(complete)
        break;
    }

    /*Future.delayed(Duration(seconds: 10),() {
        _counter++;
        s.progress++;
        _streamController.add(s);
      });*/
  }
  //getUpdates();
  //<Future>void getTasks
}