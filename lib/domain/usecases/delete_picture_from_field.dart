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

//enum PictureParentTypeEnum {taskField,taskComment}


class DeletePictureToTaskField extends UseCase<FileModel, DeletePictureToTaskFieldParams>{
  final TaskRepository taskRepository;
  //final FileRepository fileRepository;
  DeletePictureToTaskField({required this.taskRepository});
  Future<Either<Failure, FileModel>> call(DeletePictureToTaskFieldParams params) async
  {

              //if(params.parent==PictureParentTypeEnum.taskField) {
                final Either fileOrFairure = await taskRepository
                    .deleteTaskFieldPicture(
                    taskFieldId: params.taskFieldId, pictureId: params.pictureId);
                return fileOrFairure.fold((l) => Left(l), (r) => Right(r));
/*              }
              else {
                final Either fileOrFairure = await taskRepository
                    .addCommentPicture(
                    taskCommentId: params.parentId, pictureId: r);
                return fileOrFairure.fold((l) => null, (r) => r);
*/
  /*  if(obj==null)
      return Left(ServerFailure());
    return Right(obj);*/
  }
}

class DeletePictureToTaskFieldParams extends Equatable{
  final int taskFieldId;
  final int pictureId;
  //final PictureParentTypeEnum parent;
  //final int? taskFieldSelectionValue;
  DeletePictureToTaskFieldParams({required this.taskFieldId, required this.pictureId});

  @override
  List<Object> get props => [];
}