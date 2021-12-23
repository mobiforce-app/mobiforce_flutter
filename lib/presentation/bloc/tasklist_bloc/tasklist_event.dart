import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';

abstract class TaskListEvent extends Equatable{
  const TaskListEvent();

  @override
  List<Object> get props => [];

}

class ListTasks extends TaskListEvent
{
  //final int page;

  ListTasks();
}

class Wait10Sec extends TaskListEvent
{
  //final int page;

  Wait10Sec();
}

class SetEmptyList extends TaskListEvent
{
  //final int page;

  SetEmptyList();
}

class RefreshListTasks extends TaskListEvent
{
  //final int page;

  RefreshListTasks();
}
class RefreshCurrenTaskInListTasks extends TaskListEvent
{
  TaskEntity task;
  RefreshCurrenTaskInListTasks({required this.task});
}
class GetTaskUpdatesFromServer extends TaskListEvent
{
  //final int page;

  GetTaskUpdatesFromServer();
}

class StartFullSync extends TaskListEvent
{
  //final int lastSyncTime;
  //final int lastUpdateCount;

  StartFullSync();
}

class BadListTasks extends TaskListEvent
{
  BadListTasks();
}