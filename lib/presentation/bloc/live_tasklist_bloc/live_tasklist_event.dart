import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';

abstract class LiveTaskListEvent extends Equatable{
  const LiveTaskListEvent();

  @override
  List<Object> get props => [];

}

class ReloadLiveTasksList extends LiveTaskListEvent
{
  //final int page;

  ReloadLiveTasksList();
}
/*
class SendSystemGeoLog extends LiveTaskListEvent
{
  final String from;
  final String till;
  //final int page;

  SendSystemGeoLog(this.from, this.till);
}
class CheckGeo extends LiveTaskListEvent
{
  //final int page;
  final String geoNotificationTitle;
  final String geoNotificationText;

  CheckGeo({required this.geoNotificationTitle, required this.geoNotificationText});
}

class Wait10Sec extends LiveTaskListEvent
{
  //final int page;

  Wait10Sec();
}

class SetEmptyList extends LiveTaskListEvent
{
  //final int page;

  SetEmptyList();
}

class RefreshListTasks extends LiveTaskListEvent
{
  //final int page;

  RefreshListTasks();
}
class ReloadTasks extends LiveTaskListEvent
{
  //final int page;

  ReloadTasks();
}
class RefreshCurrenTaskInListTasks extends LiveTaskListEvent
{
  TaskEntity task;
  RefreshCurrenTaskInListTasks({required this.task});
}
class GetTaskUpdatesFromServer extends LiveTaskListEvent
{
  //final int page;

  GetTaskUpdatesFromServer();
}

class StartFullSync extends LiveTaskListEvent
{
  //final int lastSyncTime;
  //final int lastUpdateCount;

  StartFullSync();
}

class BadListTasks extends LiveTaskListEvent
{
  BadListTasks();
}

 */