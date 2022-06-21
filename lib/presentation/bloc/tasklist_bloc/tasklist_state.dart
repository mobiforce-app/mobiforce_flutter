import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';

abstract class TaskListState extends Equatable{
  const TaskListState();

  @override
  List<Object> get props => [];

}
class TaskListEmpty extends TaskListState{}

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

class TaskListLoaded extends TaskListState{
  final List<TaskEntity> tasksList;
  final bool changed;
  final int addFromMobileTemplates;

  TaskListLoaded({required this.tasksList,required this.changed,required this.addFromMobileTemplates});

  @override
  List<Object> get props => [tasksList, changed];

}

class TaskListError extends TaskListState{
  final String message;

  TaskListError({required this.message});

  @override
  List<Object> get props => [message];
}