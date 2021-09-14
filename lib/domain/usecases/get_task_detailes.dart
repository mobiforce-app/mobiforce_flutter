import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';

class GetTask extends UseCase<TaskEntity, TaskParams>{
  final TaskRepository taskRepository;
  GetTask(this.taskRepository);
  Future<Either<Failure, TaskEntity>> call(TaskParams params) async => await taskRepository.getTask(params.id);
}

class TaskParams extends Equatable{
  final int id;
  TaskParams({required this.id});

  @override
  List<Object> get props => [id];
}