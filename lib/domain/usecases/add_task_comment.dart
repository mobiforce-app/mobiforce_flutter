import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/data/models/task_comment_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_comment_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';

class AddTaskComment extends UseCase<List<TaskCommentEntity>, AddTaskCommentParams>{
  final TaskRepository taskRepository;
  AddTaskComment(this.taskRepository);
  Future<Either<Failure, List<TaskCommentEntity>>> call(AddTaskCommentParams params) async => await taskRepository.addTaskComment(comment:params.comment);
}

class AddTaskCommentParams extends Equatable{
  final TaskCommentModel comment;

  AddTaskCommentParams(this.comment);

  @override
  List<Object> get props => [];
}