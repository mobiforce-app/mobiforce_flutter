import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/data/models/task_comment_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_comment_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_life_cycle_node_entity.dart';
import 'package:mobiforce_flutter/domain/entity/tasksstatuses_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';

abstract class TaskState extends Equatable{
  const TaskState();

  @override
  List<Object> get props => [];

}

class TaskEmpty extends TaskState{}

class StartLoadingTaskPage extends TaskState{}
/*
class GoToFullSync extends TaskListState{
  //final int lastSyncTime;
  //final int lastUpdateCount;
  GoToFullSync();
}

class TaskListLoading extends TaskListState{
  final List<TaskEntity> oldPersonList;
  final bool isFirstFetch;

  TaskListLoading(this.oldPersonList, {this.isFirstFetch = false});

  @override
  List<Object> get props => [oldPersonList];
}
*/
class TaskLoaded extends TaskState{
  final TaskEntity task;
  final bool isChanged;
  final bool showCommentTab;
  final bool needToUpdateTaskList;
  final String appFilesDirectory;
  final List<TaskLifeCycleNodeEntity>? nextTaskStatuses;
  final List<TaskCommentEntity> comments;

  TaskLoaded({
    required this.task,
    required this.needToUpdateTaskList,
    required this.isChanged,
    this.nextTaskStatuses,
    required this.appFilesDirectory,
    required this.comments,
    required this.showCommentTab
  });

  @override
  List<Object> get props => [isChanged];

}
class TaskSaved extends TaskState{
  final TaskEntity? task;
  final List<TaskLifeCycleNodeEntity>? nextTaskStatuses;

  TaskSaved({this.task,this.nextTaskStatuses});

  @override
  List<Object> get props => [];

}

class TaskError extends TaskState{
  final String message;

  TaskError({required this.message});

  @override
  List<Object> get props => [message];
}