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
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:path_provider/path_provider.dart';

//enum PictureSourceEnum {camera,bytes}


class SaveFileDescription extends UseCase<int, SaveFileDescriptionParams>{
  //final TaskRepository taskRepository;
  final FileRepository fileRepository;
  SaveFileDescription({required this.fileRepository});
  Future<Either<Failure, int>> call(SaveFileDescriptionParams params) async
  {
    print("readFile param ${params.file.id}");
    await fileRepository.saveFileDescription(params.file);
    return Right(1);
  }
}

class SaveFileDescriptionParams extends Equatable{
  //final PictureSourceEnum src;
  //final Uint8List? data;
  //final int taskFieldSelectionValue;
  final FileModel file;
  SaveFileDescriptionParams(this.file);

  @override
  List<Object> get props => [];
}