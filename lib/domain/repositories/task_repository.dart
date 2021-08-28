import 'package:dartz/dartz.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';

abstract class TaskRepository{
  Future<Either<Failure, List<TaskEntity>>>searchTask(String query);

  Future<Either<Failure, List<TaskEntity>>>getAllTasks(int page);

}