import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';

import '../../../domain/entity/calendar_date_entity.dart';

abstract class CalendarState extends Equatable{
  const CalendarState();

  @override
  List<Object> get props => [];

}
class CalendarListEmpty extends CalendarState{}

class GoToFullSync extends CalendarState{
  //final int lastSyncTime;
  //final int lastUpdateCount;
  GoToFullSync();
}

class TaskListLoading extends CalendarState{
  final List<TaskEntity> oldPersonList;
  final bool isFirstFetch;

  TaskListLoading(this.oldPersonList, {this.isFirstFetch = false});

  @override
  List<Object> get props => [oldPersonList];
}

class CalendarDatesLoaded extends CalendarState{
  final List<CalendarMounthEntity> mounthList;
  final int position;
  final int mounthCount;
  final int selectedDay;
  CalendarDatesLoaded({required this.mounthList, required this.mounthCount, required this.position, required this.selectedDay});

  @override
  List<Object> get props => [mounthCount, selectedDay];

}

class TaskListError extends CalendarState{
  final String message;

  TaskListError({required this.message});

  @override
  List<Object> get props => [message];
}