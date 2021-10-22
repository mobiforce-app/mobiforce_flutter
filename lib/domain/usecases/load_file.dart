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


class LoadFile extends UseCase<int, LoadFileParams>{
  //final TaskRepository taskRepository;
  final FileRepository fileRepository;
  LoadFile({required this.fileRepository});
  Future<Either<Failure, int>> call(LoadFileParams params) async
  {
    print("readFile param ${params.id}");
    fileRepository.loadFromWebPicture(params.id);
    return Right(1);
  }
}

class LoadFileParams extends Equatable{
  //final PictureSourceEnum src;
  //final Uint8List? data;
  //final int taskFieldSelectionValue;
  final int id;
  LoadFileParams(this.id);

  @override
  List<Object> get props => [];
}