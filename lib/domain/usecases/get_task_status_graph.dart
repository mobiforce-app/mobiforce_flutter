import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';

class GetTaskStatusesGraph extends UseCase<List<TaskStatusEntity>, TaskStatusParams>{
  final TaskRepository taskRepository;
  GetTaskStatusesGraph(this.taskRepository);
  Future<Either<Failure, List<TaskStatusEntity>>> call(TaskStatusParams params) async => await taskRepository.getTaskStatusGraph(params.id, params.lifecycle);
}

class TaskStatusParams extends Equatable{
  final int? id;
  final int? lifecycle;
  TaskStatusParams({this.id, this.lifecycle});

  @override
  List<Object> get props => [];
}