import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobiforce_flutter/core/error/exception.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/platform/network_info.dart';
import 'package:mobiforce_flutter/data/datasources/task_remote_data_sources.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/picture_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:path_provider/path_provider.dart';

class FileRepositoryImpl implements FileRepository{
  final TaskRemoteDataSources remoteDataSources;

  FileRepositoryImpl({required this.remoteDataSources});

  @override
  Future<Either<Failure, int>>savePicture({required XFile picture}) async {
    //bool res = await remoteDataSources.setTaskFieldSelectionValue(taskField:taskField);
    //if(res)
    final directory = await getApplicationDocumentsDirectory();
    //final path = await _localPath;
    print('${directory.path}/photo.jpg');
    int id= await remoteDataSources.newTaskPicture();
    final file = File('${directory.path}/photo_$id.jpg');
    List<int> bytes = await picture.readAsBytes();
    file.writeAsBytes(bytes);

    return Right(id);
  }
}