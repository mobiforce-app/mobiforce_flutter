import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';

class SaveNewTask extends UseCase<TaskEntity, SaveNewTaskParams>{
  final TaskRepository taskRepository;
  SaveNewTask(this.taskRepository);
  Future<Either<Failure, TaskEntity>> call(SaveNewTaskParams params) async => await taskRepository.saveNewTask(
      task:params.task
  );
}

class SaveNewTaskParams extends Equatable{
  final TaskEntity task;

  SaveNewTaskParams({
    required this.task,

  });

  @override
  List<Object> get props => [];
}