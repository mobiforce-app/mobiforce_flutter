import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';

import '../entity/employee_entity.dart';
import '../entity/user_setting_entity.dart';

class GetUserSetting extends UseCase<UserSettingEntity, UserSettingParams>{
  final TaskRepository taskRepository;
  GetUserSetting(this.taskRepository);
  Future<Either<Failure, UserSettingEntity>> call(UserSettingParams params) async => await taskRepository.getUserSetting();
}

class UserSettingParams extends Equatable{
  final int id;
  UserSettingParams({required this.id});

  @override
  List<Object> get props => [id];
}