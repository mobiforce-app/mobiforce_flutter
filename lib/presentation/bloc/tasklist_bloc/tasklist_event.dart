import 'package:equatable/equatable.dart';

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

class RefreshListTasks extends TaskListEvent
{
  //final int page;

  RefreshListTasks();
}