import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/data/models/sync_status_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/domain/entity/sync_entity.dart';
import 'package:mobiforce_flutter/domain/entity/sync_object_entity.dart';
import 'package:mobiforce_flutter/domain/entity/sync_status_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/full_sync_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/sync_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';

class FullSyncFromServer extends UseCase<SyncStatusEntity, FullSyncParams>{
  final FullSyncRepository fullSyncRepository;
  final SyncRepository syncRepository;
  final DBProvider db;
  //int syncId
  FullSyncFromServer({required this.fullSyncRepository,required this.syncRepository,required  this.db});
  Future<Either<Failure, SyncStatusEntity>> call(FullSyncParams params) async {
    final dataFromWeb = await fullSyncRepository.getNext(params.syncId);
    return dataFromWeb.fold(
            (failure) {
              return Left(failure);
              },
            (sync) async {
              if(sync.dataList.isEmpty) {
                print ("empty");
                //await sharedPreferences.getBool("full_sync")??false;
                if(await fullSyncRepository.setComplete()) {
                  syncRepository.reloadUSN();
                  return Right(SyncStatusModel(progress: 100,
                      complete: true,
                      objectType: sync.objectType,
                      dataLength: 0,
                      syncPhase: SyncPhase.fullSyncStart,
                      sendToken:false,
                  ));
                }
                else
                  return Right(SyncStatusModel(progress: 100,
                      complete: false,
                      objectType: sync.objectType,
                      dataLength: 0,
                      syncPhase: SyncPhase.fullSyncStart,
                      sendToken:false,
                  ));
              }
              else {
                int id=0;
//                if(sync.objectType=="task")
                print("sync.dataList ${sync.dataList}");
                  for(dynamic object in sync.dataList) {
                    //id = task.serverId;
                    print("ObjectModel.externalId = ${object.serverId}");
                    //DateTime d1 = DateTime.now();
                    //Timeline.startSync('Task Insert To DB');
                    //print("ObjectModel = ${object.toString()}");
                    await object.insertToDB(db);
                    //DateTime d2 = DateTime.now();
                    //Timeline.finishSync();
                    //print("Time = ${d2.difference(d1)}");
                  }
                  await fullSyncRepository.commit();

                /*else if(sync.objectType=="resolution")
                  for(ResolutionModel task in sync.dataList) {
                    //id = task.serverId;
                    print("ResolutionModel.externalId = ${task.serverId}");
                    db.insertTask(task);
                  }*/
                //fullSyncRepository.saveProgress(sync.dataProgress+sync.dataList.length,id);
                //await sharedPreferences.getBool("full_sync")??false;
                return Right(SyncStatusModel(
                    progress: sync.dataProgress,
                    complete: false,
                    dataLength: sync.dataLength,
                    objectType: sync.objectType,
                    syncPhase: SyncPhase.fullSyncStart,
                    sendToken:false,
                ));
              }
            });
    //return Left(ServerFailure());
  }
}

class FullSyncParams extends Equatable{
  int syncId;
  FullSyncParams(this.syncId);
  @override
  List<Object> get props => [true];
}

