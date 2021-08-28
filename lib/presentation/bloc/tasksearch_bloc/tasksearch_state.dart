import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:meta/meta.dart';

abstract class TaskSearchState extends Equatable{
  const TaskSearchState();

  @override
  List<Object> get props => [];

}
class TaskEmpty extends TaskSearchState{}

class TaskSearchLoading extends TaskSearchState{}

class TaskSearchLoaded extends TaskSearchState{
  final List<TaskEntity> tasks;

  TaskSearchLoaded({required this.tasks});

  @override
  List<Object> get props => [tasks];

}

class TaskSearchError extends TaskSearchState{
  final String message;

  TaskSearchError({required this.message});

  @override
  List<Object> get props =>[message];
}