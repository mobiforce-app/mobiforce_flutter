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

    if(syncRepository.isFullSyncStarted())
      return Right(SyncStatusModel(syncPhase: SyncPhase.fullSyncResume,progress: 0,complete: false,dataLength: 0));
    //return await syncRepository.getUpdates();
    //return await syncRepository.getUpdates();
    final faiureOrLoading = await syncRepository.getUpdates();
    return faiureOrLoading.fold((failure){
      //print ("*")
      return Left(failure);
    }, (sync) async{
      if(sync.fullSync){
      //if(sync.syncPhase == SyncPhase.fullSyncStart) {
        await db.clear();
        await fullSyncRepository.restartFullSync(lastSyncTime:sync.lastSyncTime);
        return Right(SyncStatusModel(syncPhase: SyncPhase.fullSyncResume,progress: 0,complete: false,dataLength: 0));
      }
      else {
        if(sync.dataList.isEmpty) {
          print ("empty");
          //await sharedPreferences.getBool("full_sync")??false;
          if(await syncRepository.setComplete())
            return Right(SyncStatusModel(progress: 0,
                complete: true,
                dataLength: 0,
                syncPhase: SyncPhase.normal));
          else
            return Right(SyncStatusModel(progress: 0,
                complete: false,
                dataLength: 0,
                syncPhase: SyncPhase.normal));
        }
        else {
          int id=0;
//                if(sync.objectType=="task")
          print("sync.dataList ${sync.dataList}");
          for(dynamic object in sync.dataList) {
            //id = task.serverId;
            print("ObjectModel.externalId = ${object.serverId}");
            //await object.insertToDB(db);
          }
          await syncRepository.commit();
          return Right(SyncStatusModel(progress: 0,
              complete: false,
              dataLength: 0,
              syncPhase: SyncPhase.normal));
          /*else if(sync.objectType=="resolution")
                  for(ResolutionModel task in sync.dataList) {
                    //id = task.serverId;
                    print("ResolutionModel.externalId = ${task.serverId}");
                    db.insertTask(task);
                  }*/
          //fullSyncRepository.saveProgress(sync.dataProgress+sync.dataList.length,id);
          //await sharedPreferences.getBool("full_sync")??false;
          return Right(SyncStatusModel(progress: sync.dataProgress,
              complete: false,
              dataLength: sync.dataLength,
              syncPhase: SyncPhase.fullSyncStart));
        }
      }

    });

  }
}

class ListSyncParams extends Equatable{
  final int lastUpdateCount;
  final int lastSyncTime;
  //ListTaskParams({required this.page});
  ListSyncParams({required this.lastSyncTime, required this.lastUpdateCount});

  @override
  List<Object> get props => [lastUpdateCount,lastSyncTime];
}

