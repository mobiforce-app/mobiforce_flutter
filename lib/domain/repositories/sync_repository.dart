import 'package:dartz/dartz.dart';
import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/data/models/sync_model.dart';
import 'package:mobiforce_flutter/data/models/sync_status_model.dart';
import 'package:mobiforce_flutter/domain/entity/sync_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';

abstract class SyncRepository{
  ///Future<Either<Failure, List<SyncEntity>>>searchTask(String query);

  Future<Either<Failure, SyncEntity>>getUpdates();
  Future<Either<Failure, int>>sendUpdates(DBProvider db);
  bool isFullSyncStarted();
  Future<bool>setComplete();
  Future<bool>commit();
  void realoadUSN();

}