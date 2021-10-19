import 'package:dartz/dartz.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/data/models/file_model.dart';
import 'package:mobiforce_flutter/data/models/task_comment_model.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_comment_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';

abstract class TaskRepository{
  Future<Either<Failure, List<TaskEntity>>>searchTask(String query);

  Future<Either<Failure, List<TaskEntity>>>getAllTasks(int page);
  Future<Either<Failure, List<TaskCommentEntity>>>getAllTaskComments(int task, int page);
  Future<Either<Failure, TaskCommentEntity>>addTaskComment( {required TaskCommentModel comment});
  Future<Either<Failure, TaskEntity>>getTask(int id);
  Future<Either<Failure, TaskEntity>>setTaskStatus({required int status,required int task,int? resolution,});
  Future<Either<Failure, bool>>setTaskFieldSelectionValue({required TasksFieldsModel taskField});
  Future<Either<Failure, List<TaskStatusEntity>>>getTaskStatusGraph(int? id);
  Future<Either<Failure, FileModel >>addTaskFieldPicture({required int taskFieldId, required int pictureId});

}