import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/data/models/file_model.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/picture_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/sync_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/template_repository.dart';
import 'package:path_provider/path_provider.dart';

//enum PictureSourceEnum {camera,bytes}


class LoadTask extends UseCase<TaskEntity, LoadTaskParams>{
  final SyncRepository syncRepository;
  final TemplateRepository remoteRepository;
  LoadTask(this.remoteRepository, this.syncRepository);
  Future<Either<Failure, TaskEntity>> call(LoadTaskParams params) async {
    syncRepository.setExchangeIntent();
    while(syncRepository.lock)
      await Future.delayed(Duration(seconds: 1));
    syncRepository.incLockSemaphore();
    syncRepository.cancelExchangeIntent();

    //while(syncRepository.lock)
    //  await Future.delayed(Duration(seconds: 1));
    //syncRepository.incLockSemaphore();
    var t = await remoteRepository.getCurrentTask(params.serverId);
    //syncRepository.decLockSemaphore();
    syncRepository.decLockSemaphore();

    return t;
  }
  /*Future<Either<Failure, int>> call(LoadTaskParams params) async
  {
    print("templateRepository param ${params.id}");
    //await fileRepository.loadFromWebPicture(params.id);
    return Right(1);
  }*/
}

class LoadTaskParams extends Equatable{
  //final PictureSourceEnum src;
  //final Uint8List? data;
  //final int taskFieldSelectionValue;
  final int id;
  final int serverId;
  LoadTaskParams(this.id, this.serverId);

  @override
  List<Object> get props => [];
}