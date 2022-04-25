import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/data/models/file_model.dart';
import 'package:mobiforce_flutter/data/models/phone_model.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/domain/entity/phone_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/picture_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:path_provider/path_provider.dart';

//enum PictureParentTypeEnum {taskField,taskComment}


class AddNewPhone extends UseCase<PhoneEntity, AddNewPhoneParams>{
  final TaskRepository taskRepository;
  //final FileRepository fileRepository;
  AddNewPhone({required this.taskRepository});
  Future<Either<Failure, PhoneEntity>> call(AddNewPhoneParams params) async => await taskRepository.addNewPhone(
  name:params.name
  );
}

class AddNewPhoneParams extends Equatable{
  final String name;
  //final PictureParentTypeEnum parent;
  //final int? taskFieldSelectionValue;
  AddNewPhoneParams({required this.name});

  @override
  List<Object> get props => [];
}