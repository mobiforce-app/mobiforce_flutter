import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];

}

class ReloadTask extends TaskEvent
{
  final int id;
  //final int page;

  ReloadTask(this.id);
}
class ChangeTaskStatus extends TaskEvent
{
  final int status;

  ChangeTaskStatus({required this.status});
}
class ChangeSelectionFieldValue extends TaskEvent
{
  final int fieldId;
  final dynamic value;
  //final int task;
  ChangeSelectionFieldValue({required this.fieldId, required this.value});
}
class ChangeTextFieldValue extends TaskEvent
{
  final int fieldId;
  final String value;
  ChangeTextFieldValue({required this.fieldId, required this.value});
}
/*
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
}*/