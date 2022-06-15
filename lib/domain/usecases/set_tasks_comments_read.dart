import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/usecases/usecase.dart';
import 'package:mobiforce_flutter/domain/entity/task_comment_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';

import '../../data/models/task_comment_model.dart';

class SetTaskCommentsRead extends UseCase<void, SetTaskCommentsReadParams>{
  final TaskRepository taskRepository;
  SetTaskCommentsRead(this.taskRepository);
  Future<Either<Failure,void>> call(SetTaskCommentsReadParams params) async => await taskRepository.setTaskCommentsRead(params.comments);
}

class SetTaskCommentsReadParams extends Equatable{
  final List<TaskCommentEntity?> comments;
  SetTaskCommentsReadParams({required this.comments});

  @override
  List<Object> get props => [comments];
}