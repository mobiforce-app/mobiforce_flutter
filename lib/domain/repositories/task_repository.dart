import 'package:dartz/dartz.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/data/models/file_model.dart';
import 'package:mobiforce_flutter/data/models/task_comment_model.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_comment_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_life_cycle_node_entity.dart';
import 'package:mobiforce_flutter/domain/entity/tasksstatuses_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';

abstract class TaskRepository{
  Future<Either<Failure, List<TaskEntity>>>searchTask(String query);

  Future<Either<Failure, TaskEntity>>saveNewTask({required TaskEntity task});
  Future<Either<Failure, List<TaskEntity>>>getAllTasks(int page);
  Future<Either<Failure, List<TaskCommentEntity>>>getAllTaskComments(int task, int page);
  Future<Either<Failure, TaskCommentEntity>>addTaskComment( {required TaskCommentModel comment});
  Future<Either<Failure, TaskEntity>>getTask(int id);
  Future<Either<Failure, TaskEntity>>setTaskStatus({
    int id,
    required int status,
    required int task,
    int? resolution,
    required String comment,
    required DateTime createdTime,
    required DateTime manualTime,
    required bool timeChanging,
    required bool dateChanging,
    required bool commentChanging,
    required bool commentRequired,
  });
  Future<Either<Failure, bool>>setTaskFieldSelectionValue({required TasksFieldsModel taskField});
  Future<Either<Failure, List<TaskLifeCycleNodeEntity>>>getTaskStatusGraph(int? id, int? lifecycle);
  Future<Either<Failure, FileModel >>addTaskFieldPicture({required int taskFieldId, required int pictureId});
  Future<Either<Failure, FileModel >>deleteTaskFieldPicture({required int taskFieldId, required int pictureId});

}