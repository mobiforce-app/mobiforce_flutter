import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
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
  final List<TaskStatusEntity> nextTaskStatuses;

  TaskLoaded({required this.task,required this.nextTaskStatuses});

  @override
  List<Object> get props => [task];

}

class TaskError extends TaskState{
  final String message;

  TaskError({required this.message});

  @override
  List<Object> get props => [message];
}