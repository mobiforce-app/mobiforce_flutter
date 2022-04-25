import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/data/models/sync_status_model.dart';
import 'package:mobiforce_flutter/domain/entity/sync_entity.dart';
import 'package:mobiforce_flutter/domain/entity/sync_status_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/full_sync_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/sync_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';

class SyncFromServer extends UseCase<SyncStatusEntity, ListSyncParams>{
  final DBProvider db;
  final SyncRepository syncRepository;
  final FullSyncRepository fullSyncRepository;
  SyncFromServer(this.syncRepository, this.db, this.fullSyncRepository);
  Future<Either<Failure, SyncStatusEntity>> call(ListSyncParams params) async {
    if (syncRepository.isFullSyncStarted())
      return Right(SyncStatusModel(syncPhase: SyncPhase.fullSyncResume,
          progress: 0,
          complete: false,
          dataLength: 0,
          objectType: "",
          sendToken: false));

    //return await syncRepository.getUpdates();
    //return await syncRepository.getUpdates();
    //if(params.fcmToken!=null) {
    final bool sendToken = await syncRepository.sendToken(params.fcmToken);
    //}

    final faiureOrLoading = await syncRepository.getUpdates();
    return await faiureOrLoading.fold((failure){
      print (failure);
      return Left(failure);
    }, (sync) async{
      if (syncRepository.dbCheckVersion(db.dbVersion))
      {

        print("serversync START rebase! ${sync.lastSyncTime} ${syncRepository.getLastSyncTime()}");

        await db.clear();
        //print("sync.lastSyncTime ${sync.lastSyncTime}");
        await fullSyncRepository.restartFullSync(lastSyncTime:syncRepository.getLastSyncTime());//sync.lastSyncTime);
        await syncRepository.dbSetVersion(db.dbVersion);
        return Right(SyncStatusModel(
            syncPhase: SyncPhase.fullSyncResume,
            objectType: "",
            progress: 0,
            complete: false,
            dataLength: 0,
            sendToken: false));
      }
      else if(sync.fullSync){
      //if(sync.syncPhase == SyncPhase.fullSyncStart) {
        await db.clear();
        await syncRepository.dbSetVersion(db.dbVersion);
        print("sync.lastSyncTime ${sync.lastSyncTime} FULL SYNC BY SERVER");
        await fullSyncRepository.restartFullSync(lastSyncTime:sync.lastSyncTime);
        return Right(SyncStatusModel(
            syncPhase: SyncPhase.fullSyncResume,
            objectType: sync.objectType,
            progress: 0,
            complete: false,
            dataLength: 0,
            sendToken: sendToken));
      }
      else {
        print("sync.lastSyncTime ${sync.lastSyncTime}");

        if(sync.dataList.isEmpty) {
          print ("empty");
          //await sharedPreferences.getBool("full_sync")??false;
          if(await syncRepository.setComplete())
            return Right(SyncStatusModel(progress: 0,
                complete: true,
                dataLength: 0,
                syncPhase: SyncPhase.normal,
                objectType: sync.objectType,
                sendToken:sendToken));
          else
            return Right(SyncStatusModel(progress: 0,
                complete: false,
                dataLength: 0,
                objectType: sync.objectType,
                syncPhase: SyncPhase.normal,
                sendToken:sendToken
            ));
        }
        else {
          int id=0;
//                if(sync.objectType=="task")
          print("sync.dataList ${sync.dataList}");
          for(dynamic object in sync.dataList) {
            //id = task.serverId;
            print("ObjectModel.externalId = ${object.serverId}");
            //if(object.deleted) {
            //  print("delete ObjectModel.externalId = ${object.serverId}");
              //object.insertByExternalId(db);
              //await object.insertToDB(db);
            //}
            //else
              //object.usn=0;
              await object.insertToDB(db);
          }
          await syncRepository.commit();
          return Right(SyncStatusModel(progress: 0,
              complete: false,
              dataLength: 0,
              objectType: sync.objectType,
              syncPhase: SyncPhase.normal,
              sendToken:sendToken));
          /*else if(sync.objectType=="resolution")
                  for(ResolutionModel task in sync.dataList) {
                    //id = task.serverId;
                    print("ResolutionModel.externalId = ${task.serverId}");
                    db.insertTask(task);
                  }*/
          //fullSyncRepository.saveProgress(sync.dataProgress+sync.dataList.length,id);
          //await sharedPreferences.getBool("full_sync")??false;
         /* return Right(SyncStatusModel(progress: sync.dataProgress,
              complete: false,
              dataLength: sync.dataLength,
              syncPhase: SyncPhase.fullSyncStart));*/
        }
      }

    });

  }
}

class ListSyncParams extends Equatable{
  final int lastUpdateCount;
  final int lastSyncTime;
  final String? fcmToken;
  //ListTaskParams({required this.page});
  ListSyncParams({required this.lastSyncTime, required this.lastUpdateCount, this.fcmToken});

  @override
  List<Object> get props => [lastUpdateCount,lastSyncTime];
}

