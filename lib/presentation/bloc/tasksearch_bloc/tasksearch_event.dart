import 'package:equatable/equatable.dart';

abstract class TaskSearchEvent extends Equatable{
  const TaskSearchEvent();

  @override
  List<Object> get props => [];

}

class SearchTasks extends TaskSearchEvent
{
  final String taskQuery;

  SearchTasks(this.taskQuery);
}