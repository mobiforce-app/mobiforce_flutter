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

import '../repositories/template_repository.dart';

class LazySyncFromServer extends UseCase<bool, LazySyncParams>{
  final DBProvider db;
  final SyncRepository syncRepository;
  final FullSyncRepository fullSyncRepository;
  LazySyncFromServer(this.syncRepository, this.db, this.fullSyncRepository);
  Future<Either<Failure, bool>> call(LazySyncParams params) async {
    print("start lazy recycle: ${syncRepository.lock}");
            if(!syncRepository.lock)
              syncRepository.incLockSemaphore();
            while(true) {
              print("lazy syncRepository.exchangeIntent: ${syncRepository.exchangeIntent}");
              if (syncRepository.exchangeIntent)
                break;

              List<int> tl = await db.getUnloadedTaskList();
              if (tl.isNotEmpty) {
                final fol = await syncRepository.getUnloadedTasks(tl);
                bool cycle = fol.fold((failure) {
                  //syncRepository.decLockSemaphore();
                  return false;
                }, (notEmpty) {
                  if (notEmpty) {
                    print("dalayedloading notEmpty");
                    //syncRepository.restartExchangeCycle()
                    //syncRepository.decLockSemaphore();
                    return true;
                  }
                  else {
                    //syncRepository.decLockSemaphore();
                    return false;
                  }
                });
                //if (!cycle) {
                 // syncRepository.decLockSemaphore();
                  //Right(true);
                //}
              }
              else {
                break;
                //return Right(false);

              }
              print("lazyRecycle");
            }
            syncRepository.decLockSemaphore();
            return Right(true);

}
}

class LazySyncParams extends Equatable{
  //ListTaskParams({required this.page});
  LazySyncParams();

  @override
  List<Object> get props => [];
}

