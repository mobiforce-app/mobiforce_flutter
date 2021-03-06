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

class SyncToServer extends UseCase<SyncStatusEntity, ListSyncToServerParams>{
  final DBProvider db;
  final SyncRepository syncRepository;
  //final FullSyncRepository fullSyncRepository;
  SyncToServer(this.syncRepository, this.db);
  Future<Either<Failure, SyncStatusEntity>> call(ListSyncToServerParams params) async {

    print("sync!!!");
    //if(syncRepository.isFullSyncStarted())
    //  return Left(failure);
    //return await syncRepository.getUpdates();
    //return await syncRepository.getUpdates();
    //db.readUpdate
    int cycle=1;
    while(cycle==1) {

      final faiureOrLoading = await syncRepository.sendUpdates(db);
      cycle =  faiureOrLoading.fold((failure) {
        //print ("*")
        //return Left(failure);
        print("Server UPDATE failure");
        return -1;
      }, (sync) {
        if(sync==0)
          return 0;
        return 1;
      });
      print("cycle: $cycle");
    }
    if(cycle==0)
      return Right(SyncStatusModel(progress: 0,
          complete: true,
          dataLength: 0,
          objectType: "",
          syncPhase: SyncPhase.normal,
          sendToken:false,
      ));
    else
      return Left(ServerFailure());

  }
}

class ListSyncToServerParams extends Equatable{
  ListSyncToServerParams();

  @override
  List<Object> get props => [];
}
