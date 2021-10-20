import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';

abstract class FileRepository{
  Future<Either<Failure, int>> savePicture({Uint8List? bytes});

}