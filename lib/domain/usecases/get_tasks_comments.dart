import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/task_comment_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';

class GetTaskComments extends UseCase<List<TaskCommentEntity>, GetTaskCommentsParams>{
  final TaskRepository taskRepository;
  GetTaskComments(this.taskRepository);
  Future<Either<Failure, List<TaskCommentEntity>>> call(GetTaskCommentsParams params) async => await taskRepository.getAllTaskComments(params.task,params.page);
}

class GetTaskCommentsParams extends Equatable{
  final int page;
  final int task;
  GetTaskCommentsParams({required this.page, required this.task});

  @override
  List<Object> get props => [page,task];
}