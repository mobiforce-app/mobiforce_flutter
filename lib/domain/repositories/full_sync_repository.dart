import 'package:dartz/dartz.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/domain/entity/sync_entity.dart';
import 'package:mobiforce_flutter/domain/entity/sync_status_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';

abstract class FullSyncRepository{
  ///Future<Either<Failure, List<SyncEntity>>>searchTask(String query);

  Future<Either<Failure, SyncEntity>>getNext(int syncId);

}