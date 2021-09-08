import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/data/models/sync_status_model.dart';
import 'package:mobiforce_flutter/domain/entity/sync_entity.dart';
import 'package:mobiforce_flutter/domain/entity/sync_object_entity.dart';
import 'package:mobiforce_flutter/domain/entity/sync_status_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/full_sync_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/sync_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';

class FullSyncFromServer extends UseCase<SyncStatusEntity, FullSyncParams>{
  final FullSyncRepository fullSyncRepository;
  //int syncId
  FullSyncFromServer(this.fullSyncRepository);
  Future<Either<Failure, SyncStatusEntity>> call(FullSyncParams params) async {
    final dataFromWeb = await fullSyncRepository.getNext(params.syncId);
    return dataFromWeb.fold(
            (failure) {
              return Left(failure);
              },
            (sync) {
              if(sync.dataList.isEmpty)
                return Right(SyncStatusModel(progress: sync.lastUpdateCount,complete:true,dataLength: 0,fullSync: true));
              else {
                int id=0;
                for(SyncObjectEntity element in sync.dataList)
                  id=element.id;
                return Right(SyncStatusModel(progress: id,
                    complete: false,
                    dataLength: 0,
                    fullSync: true));
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

