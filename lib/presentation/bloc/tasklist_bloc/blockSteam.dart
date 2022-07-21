import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/domain/entity/sync_status_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/firebase.dart';
import 'package:mobiforce_flutter/domain/usecases/sync_from_server.dart';
import 'package:mobiforce_flutter/domain/usecases/sync_to_server.dart';

import '../../../domain/usecases/lazysync_from_server.dart';
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
  final LazySyncFromServer lazySyncFromServer;
  final SyncToServer syncToServer;
  final PushNotificationService fcm;
  bool fcmTokenNotSync = true;
  bool updateInProgress=false;
  ModelImpl({required this.syncFromServer,required this.syncToServer,required this.fcm, required this.lazySyncFromServer});

  SyncStatus s = SyncStatus(syncPhase:SyncPhase.normal);
  //var controller = new StreamController<String>();
  StreamController _streamController = new StreamController<SyncStatus>();

  Stream<dynamic> get counterUpdates => _streamController.stream;

  Future<void> startUpdate() async {
    print("startUpdate()");
    if(updateInProgress)
      return;
    updateInProgress=true;
    while(true)
    {
      print("startUpdate() recycle");

      final fOL = await syncToServer(ListSyncToServerParams());
      bool completeWithErr=fOL.fold((failure) {return true;},(sync) {return false;});
      if(completeWithErr)
        break;
        //syncFromServer
      print("startUpdate() syncFromServer");
      final faiureOrLoading = await syncFromServer(ListSyncParams(
        lastSyncTime: 0,
        lastUpdateCount: 0,
          fcmToken: fcmTokenNotSync?fcm.token:null
      ));
      print("serversync");

      bool complete=faiureOrLoading.fold((failure) {
        print ("*");
        //failure.
        if(failure == NoInternetConnection()) {
          _streamController.add(SyncStatus(syncPhase:SyncPhase.normalSyncComplete));
          return true;
        }
        return false;
      }, (sync) {
        if(sync.sendToken)
          fcmTokenNotSync=false;
        // open full sync page
        print("fullSync ${sync.syncPhase}");
        if(sync.syncPhase != SyncPhase.normal)
        {
          _streamController.add(SyncStatus(syncPhase:sync.syncPhase));
          return true;
        }
        else{
          if(sync.complete)
            _streamController.add(SyncStatus(syncPhase:SyncPhase.normalSyncComplete));
        }
        return sync.complete;
        //print("**");
      });
      if(complete)
        break;
    }
    lazySyncFromServer(LazySyncParams());
    updateInProgress=false;
    /*Future.delayed(Duration(seconds: 10),() {
        _counter++;
        s.progress++;
        _streamController.add(s);
      });*/
  }
  //getUpdates();
  //<Future>void getTasks
}