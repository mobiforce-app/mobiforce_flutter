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
class SendSystemGeoLog extends TaskListEvent
{
  final String from;
  final String till;
  //final int page;

  SendSystemGeoLog(this.from, this.till);
}
class CheckGeo extends TaskListEvent
{
  //final int page;
  final String geoNotificationTitle;
  final String geoNotificationText;

  CheckGeo({required this.geoNotificationTitle, required this.geoNotificationText});
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
class ReloadTasks extends TaskListEvent
{
  //final int page;

  ReloadTasks();
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