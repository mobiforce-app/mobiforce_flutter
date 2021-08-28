import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';

abstract class TaskListState extends Equatable{
  const TaskListState();

  @override
  List<Object> get props => [];

}
class TaskListEmpty extends TaskListState{}

class TaskListLoading extends TaskListState{
  final List<TaskEntity> oldPersonList;
  final bool isFirstFetch;

  TaskListLoading(this.oldPersonList, {this.isFirstFetch = false});

  @override
  List<Object> get props => [oldPersonList];
}

class TaskListLoaded extends TaskListState{
  final List<TaskEntity> tasksList;

  TaskListLoaded({required this.tasksList});

  @override
  List<Object> get props => [tasksList];

}

class TaskListError extends TaskListState{
  final String message;

  TaskListError({required this.message});

  @override
  List<Object> get props => [message];
}