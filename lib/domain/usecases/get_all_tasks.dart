import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';

class GetAllTasks extends UseCase<List<TaskEntity>, ListTaskParams>{
  final TaskRepository taskRepository;
  GetAllTasks(this.taskRepository);
  Future<Either<Failure, List<TaskEntity>>> call(ListTaskParams params) async => await taskRepository.getAllTasks(params.page);
}

class ListTaskParams extends Equatable{
  final int page;
  ListTaskParams({required this.page});

  @override
  List<Object> get props => [page];
}