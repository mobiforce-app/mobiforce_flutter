import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';

abstract class LiveTaskListState extends Equatable{
  const LiveTaskListState();

  @override
  List<Object> get props => [];

}
class TaskListEmpty extends LiveTaskListState{}

class ReloadingLiveTasksList extends LiveTaskListState{
  //final int lastSyncTime;
  //final int lastUpdateCount;
  ReloadingLiveTasksList();
}

class TaskListLoading extends LiveTaskListState{
  final List<TaskEntity> oldPersonList;
  final bool isFirstFetch;

  TaskListLoading(this.oldPersonList, {this.isFirstFetch = false});

  @override
  List<Object> get props => [oldPersonList];
}

class LiveTaskListLoaded extends LiveTaskListState{
  final List<TaskEntity> tasksList;
  final bool changed;

  LiveTaskListLoaded({required this.tasksList,required this.changed});

  @override
  List<Object> get props => [tasksList, changed];

}

class TaskListError extends LiveTaskListState{
  final String message;

  TaskListError({required this.message});

  @override
  List<Object> get props => [message];
}