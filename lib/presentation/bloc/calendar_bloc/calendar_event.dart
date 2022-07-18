import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';

abstract class CalendarEvent extends Equatable{
  const CalendarEvent();

  @override
  List<Object> get props => [];

}

class ListTasks extends CalendarEvent
{
  //final int page;

  ListTasks();
}
class SetCurrentDate extends CalendarEvent
{
  final Future<List<int>> Function(DateTime start, DateTime finish)? additionInfo;

  //final int page;

  SetCurrentDate(this.additionInfo);
}
class AddRight extends CalendarEvent
{
  final Future<List<int>> Function(DateTime start, DateTime finish)? additionInfo;
  //final int page;

  AddRight(this.additionInfo);
}
class AddLeft extends CalendarEvent
{
  final Future<List<int>> Function(DateTime start, DateTime finish)? additionInfo;
  //final int page;

  AddLeft(this.additionInfo);
}
class SendSystemGeoLog extends CalendarEvent
{
  final String from;
  final String till;
  //final int page;

  SendSystemGeoLog(this.from, this.till);
}
class CheckGeo extends CalendarEvent
{
  //final int page;
  final String geoNotificationTitle;
  final String geoNotificationText;

  CheckGeo({required this.geoNotificationTitle, required this.geoNotificationText});
}

class Wait10Sec extends CalendarEvent
{
  //final int page;

  Wait10Sec();
}

class SelectDay extends CalendarEvent
{
  final int id;
  final DateTime selectedDate;
  final void Function() callback;

  SelectDay(this.id, this.selectedDate, this.callback);
}

class RefreshListTasks extends CalendarEvent
{
  //final int page;

  RefreshListTasks();
}
class RefreshCurrenTaskInListTasks extends CalendarEvent
{
  TaskEntity task;
  RefreshCurrenTaskInListTasks({required this.task});
}
class GetTaskUpdatesFromServer extends CalendarEvent
{
  //final int page;

  GetTaskUpdatesFromServer();
}

class StartFullSync extends CalendarEvent
{
  //final int lastSyncTime;
  //final int lastUpdateCount;

  StartFullSync();
}

class BadListTasks extends CalendarEvent
{
  BadListTasks();
}