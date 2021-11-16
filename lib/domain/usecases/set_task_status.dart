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
  Future<Either<Failure, TaskEntity>> call(SetTaskStatusParams params) async => await taskRepository.setTaskStatus(
      id:params.id??0,
      status:params.status,
      task:params.task,
      resolution:params.resolution,
      comment:params.comment,
      createdTime:params.createdTime,
      manualTime:params.manualTime,
      timeChanging:params.timeChanging,
      dateChanging:params.dateChanging,
      commentChanging:params.commentChanging,
      commentRequired:params.commentRequired,
  );
}

class SetTaskStatusParams extends Equatable{
  final int? id;
  final int task;
  final int status;
  int? resolution;
  String comment;
  DateTime createdTime;
  DateTime manualTime;
  bool timeChanging;
  bool dateChanging;
  bool commentChanging;
  bool commentRequired;

  SetTaskStatusParams({
    this.id,
    required this.task,
    required this.comment,
    required this.createdTime,
    required this.manualTime,
    required this.status,
    this.resolution,
    required this.timeChanging,
    required this.dateChanging,
    required this.commentChanging,
    required this.commentRequired,
  });

  @override
  List<Object> get props => [];
}