import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';

class SearchTask extends UseCase<List<TaskEntity>, SearchTaskParams>{
  final TaskRepository taskRepository;
  SearchTask(this.taskRepository);
  Future<Either<Failure, List<TaskEntity>>> call(SearchTaskParams params) async => await taskRepository.searchTask(params.query);
}

class SearchTaskParams extends Equatable{
  final String query;
  SearchTaskParams({required this.query});

  @override
  List<Object> get props => [query];
}