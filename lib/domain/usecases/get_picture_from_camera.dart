import 'dart:io';

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

class GetPictureFromCamera extends UseCase<FileModel, GetPictureFromCameraParams>{
  final TaskRepository taskRepository;
  final FileRepository fileRepository;
  GetPictureFromCamera({required this.taskRepository,required this.fileRepository});
  Future<Either<Failure, FileModel>> call(GetPictureFromCameraParams params) async
  {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 2000,
      maxHeight: 2000,
      imageQuality: 80,
    );

    final Either addResult = await fileRepository.savePicture(picture: pickedFile!);
    final obj = await addResult.fold((l) => null,
            (r) async {
              print("Picture $r.");
              final Either fileOrFairure = await taskRepository.addTaskFieldPicture(
                  taskFieldId: params.taskFieldId, pictureId: r);
              return fileOrFairure.fold((l) => null, (r) => r);
            }
            );
    if(obj==null)
      return Left(ServerFailure());
    return Right(obj);
  }
}

class GetPictureFromCameraParams extends Equatable{
  final int taskFieldId;
  //final int? taskFieldSelectionValue;
  GetPictureFromCameraParams({required this.taskFieldId});

  @override
  List<Object> get props => [];
}