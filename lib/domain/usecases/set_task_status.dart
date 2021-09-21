import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';

class SetTaskStatus extends UseCase<TaskEntity, SetTaskStatusParams>{
  final TaskRepository taskRepository;
  SetTaskStatus(this.taskRepository);
  Future<Either<Failure, TaskEntity>> call(SetTaskStatusParams params) async => await taskRepository.setTaskStatus(status:params.status,task:params.task);
}

class SetTaskStatusParams extends Equatable{
  final int task;
  final int status;
  SetTaskStatusParams({required this.task,required this.status});

  @override
  List<Object> get props => [];
}