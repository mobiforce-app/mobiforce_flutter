import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/sync_entity.dart';
import 'package:mobiforce_flutter/domain/entity/sync_status_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/sync_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';

class SyncFromServer extends UseCase<SyncStatusEntity, ListSyncParams>{
  final SyncRepository syncRepository;
  SyncFromServer(this.syncRepository);
  Future<Either<Failure, SyncStatusEntity>> call(ListSyncParams params) async => await syncRepository.getUpdates();
}

class ListSyncParams extends Equatable{
  final int lastUpdateCount;
  final int lastSyncTime;
  //ListTaskParams({required this.page});
  ListSyncParams({required this.lastSyncTime, required this.lastUpdateCount});

  @override
  List<Object> get props => [lastUpdateCount,lastSyncTime];
}

