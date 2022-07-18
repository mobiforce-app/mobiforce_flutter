import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/domain/entity/sync_status_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/firebase.dart';
import 'package:mobiforce_flutter/domain/usecases/authorization_check.dart';
import 'package:mobiforce_flutter/domain/usecases/get_all_tasks.dart';
import 'package:mobiforce_flutter/domain/usecases/wait.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/blockSteam.dart';
//import 'package:mobiforce_flutter/domain/usecases/search_task.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_state.dart';
import 'package:collection/collection.dart';

import '../../../domain/entity/calendar_date_entity.dart';
import '../../../domain/usecases/SendGeoLog.dart';
import '../../../domain/usecases/get_task_templates.dart';
import '../../../domain/usecases/set_task_list_filter.dart';
import '../../../domain/usecases/start_geolocation_service.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';
//import 'package:dartz/dartz.dart';
// import 'equatabl'
class CalendarBloc extends Bloc<CalendarEvent,CalendarState>{
  DateTime leftDay = DateTime.now();
  DateTime rightDay = DateTime.now();
  DateTime first = DateTime.now();
  SetTaskListFilter setTaskListFilter;
  //final WaitDealys10 wait10;

  //final _counterStreamController = StreamController<int>();
  //StreamSink<int> get counter_sink => _counterStreamController.sink;
// expose data from stream
//  Stream<int> get stream_counter => _counterStreamController.stream;
  //final _counterStreamController = StreamController<TaskEntity>();
  //Stream<TaskEntity> get stream_counter => _counterStreamController.stream;


  int page = 0;
  CalendarBloc(this.setTaskListFilter) : super(CalendarListEmpty())
  {
   /* m.counterUpdates.listen((item){
      print("m.counterUpdates item.progress ${item.syncPhase}");
      if(item.syncPhase==SyncPhase.normalSyncComplete)
      {
        print("complete");
        this.add(RefreshListTasks());
      }
      else //if(item)
        this.add(StartFullSync());
    });
    m.startUpdate();
    print("start");*/
  }


  //StreamSubscription streamSubscription = MyApp.model.counterUpdates.listen((newVal) => setState(() {
  //_counter = newVal;
  //}));
  //
  Future<List<CalendarDateEntity>> getMonthDays(DateTime date, Future<List<int>> Function(DateTime start, DateTime finish)? additionInfo) async
  {
    //final int daysFromBegin = date.day;
    final DateTime firstDayInMonth = DateTime(date.year, date.month, 1);
    final DateTime firstDayInNextMonth = DateTime(date.year, date.month+1, 1);
    int dayInMounth=firstDayInNextMonth.difference(firstDayInMonth).inDays;
    List<CalendarDateEntity> days=[];
    List<int>? tasks = null;
    if(additionInfo!=null)
      tasks = await additionInfo(firstDayInMonth,firstDayInNextMonth);
    else
      print("additional info = null");
    print("tasks $tasks");
    for(int i=0;i<dayInMounth;i++){
      DateTime current = firstDayInMonth
          .add(Duration(days: i));
      days.add(CalendarDateEntity(id: current.year*10000+current.month*100+current.day, tasks:(tasks?[i])??0, date: current, name: "${current
          .day}", weekDay: current.weekday));

    }
    return days;
  }

  @override
  Stream<CalendarState> mapEventToState(CalendarEvent event) async* {
    print("CalendarState event: $event");
    if(event is AddRight) {
      final currentState = state as CalendarDatesLoaded;
      var mounthList = currentState.mounthList;
      //yield CalendarListEmpty();
      final days = await getMonthDays(rightDay.add(Duration(days: 1)), event.additionInfo);
      rightDay = days.last.date;
      String year = first.year!=days.last.date.year?"${days.last.date.year}":"";
      print("additional info ${days.first.date}");
      mounthList.add(CalendarMounthEntity(id: days.first.date.month-1, yearString: year, name: "${days.first.date.month}", days: days));
      yield CalendarDatesLoaded(mounthList:mounthList,mounthCount:mounthList.length, position: 0, selectedDay: currentState.selectedDay);
    }
    else if(event is SelectDay) {

      final currentState = state as CalendarDatesLoaded;

      final dayId = event.id==currentState.selectedDay?0:event.id;
      if(dayId!=0)
        setTaskListFilter(dateFrom: event.selectedDate,dateTill: event.selectedDate.add(Duration(days: 1)));
      else
        setTaskListFilter(dateFrom: null,dateTill: null);
      event.callback();
      print("event.id: ${event.id}");
      yield CalendarListEmpty();

      yield CalendarDatesLoaded(
          mounthList:currentState.mounthList,
          mounthCount:currentState.mounthList.length,
          position: 0,
          selectedDay: dayId
      );
    }
    else if(event is AddLeft) {
      final currentState = state as CalendarDatesLoaded;
      var mounthList = currentState.mounthList;
      //yield CalendarListEmpty();
      final days = await getMonthDays(leftDay.subtract(Duration(days: 1)), event.additionInfo);
      leftDay = days.first.date;
      String year = first.year!=days.last.date.year?"${days.last.date.year}":"";
      print("additional info ${days.first.date}");
      mounthList.insert(0, CalendarMounthEntity(id: days.first.date.month-1, yearString: year, name: "${days.first.date.month}", days: days));
      yield CalendarDatesLoaded(mounthList:mounthList,mounthCount:mounthList.length, position: days.length, selectedDay: currentState.selectedDay);
    }
    else if(event is SetCurrentDate){
      print("SetCurrentDate");
      //yield CalendarDatesLoaded(daysList:[], position: 0);

      final DateTime current=DateTime.now();
      List<CalendarMounthEntity> mounthList=[];
      final days = await getMonthDays(current, event.additionInfo);
      leftDay = days.first.date;
      rightDay = days.last.date;
      String year = first.year!=days.last.date.year?"${days.last.date.year}":"";
      print("additional info ${days.first.date}");
      mounthList.add(CalendarMounthEntity(id: days.first.date.month-1, yearString: year, name: "${days.first.date.month}", days: days));

      yield CalendarDatesLoaded(mounthList:mounthList,mounthCount:mounthList.length, position: current.day-1, selectedDay: 0);
      //print("start sync1");
      //yield TaskListEmpty();
    }
    else
      yield CalendarListEmpty();
/*    print("tasklist bloc map event "+event.toString());
    if(event is StartFullSync){
      print("start sync");
      yield GoToFullSync();
      //print("start sync1");
      //yield TaskListEmpty();
    }
    if (event is SendSystemGeoLog) {
      //sendGeo
      print("SendSystemGeoLog");
      final faiureOrLoading = await geoLogSender(event.from, event.till);

    }
    if(event is CheckGeo){
      print("startGeolocationService");
      startGeolocationService(geoNotificationTitle: event.geoNotificationTitle, geoNotificationText: event.geoNotificationText);
    }
    if(event is GetTaskUpdatesFromServer){
      m.startUpdate();
    }
    if(event is SetEmptyList){
    //   print("start sync");
      yield TaskListEmpty();
    }
    if(event is ListTasks){
      yield* _mapFetchTaskToState();
    }
    if(event is BadListTasks){
      print("wait 10 sec");
      yield TaskListError(message: "111");
    }
    else if(event is RefreshListTasks){
      print("map event!");
      yield* _mapRefreshTaskToState();
      /*Future.delayed(Duration(seconds: 10),() {
        _counterStreamController.add(TaskEntity(id: 0, serverId: 0, unreadedCommentCount: 0));
      });*/
    }
    else if(event is RefreshCurrenTaskInListTasks){
      print("RefreshCurrenTaskInListTasks!");
      final currentState = state;
      //SyncReady();
      //yield Stream.fromFutures([wait10()]).listen(listener);
      var oldTasks = <TaskEntity>[];
      if(currentState is TaskListLoaded)
      {
        oldTasks = currentState.tasksList;
        int addFromMobileTemplates = currentState.addFromMobileTemplates;
        TaskEntity? neededTask;
        neededTask = oldTasks.firstWhereOrNull((element) => element.id == event.task.id);
        print("try to find task id ${event.task.id}");
        if(neededTask!=null) {
          print("task found!");
          int ind = oldTasks.indexOf(neededTask);
          print("task found! $ind");

          oldTasks[ind] = event.task;
          yield TaskListLoaded(tasksList: oldTasks, changed: !currentState.changed, addFromMobileTemplates: addFromMobileTemplates);
        }
      }
**/

      //yield* _mapRefreshTaskToState();
    //}
  }
  Stream<TaskListState> _mapRefreshTaskToState() async*{
  /*  final currentState = state;
    page = 0;
    var oldTasks = <TaskEntity>[];
    //int addFromMobileTemplates = currentState.addFromMobileTemplates;
    //m.incrementCounter();
    /*if(currentState is TaskListLoaded)
    {
      oldTasks = currentState.tasksList;
    }
*/
    final fOl = await taskTemplatesList(ListTemplateParams(page:0));
    int addFromMobileTemplates = fOl.fold((failure)=>0, (task) {
      print("templates: ${task.length}");
      return task.length;
    });
    yield TaskListLoading(oldTasks,isFirstFetch: page==0);
    final faiureOrLoading = await listTask(ListTaskParams(page: page));

    yield faiureOrLoading.fold((failure)=>TaskListError(message:_mapFailureToMessage(failure)), (task) {
      page++;
      //final tasks = (state as TaskListLoading).oldPersonList;
      //tasks.addAll(task);
      return TaskListLoaded(tasksList: task, changed: true, addFromMobileTemplates: addFromMobileTemplates);
    });//TaskListLoaded(tasksList: task));

*/
  }

  Stream<TaskListState> _mapFetchTaskToState() async*{
 /*   final currentState = state;
    //SyncReady();
    //yield Stream.fromFutures([wait10()]).listen(listener);
    var oldTasks = <TaskEntity>[];
    int addFromMobileTemplates = 0;
    if(currentState is TaskListLoaded)
    {
      oldTasks = currentState.tasksList;
      addFromMobileTemplates = currentState.addFromMobileTemplates;
    }

    yield TaskListLoading(oldTasks,isFirstFetch: page==0);
    print("page: $page");
    final faiureOrLoading = await listTask(ListTaskParams(page: page));
    //yield TaskListLoaded(tasksList: oldTasks, changed: true, addFromMobileTemplates: addFromMobileTemplates);

    yield faiureOrLoading.fold(
            (failure) => TaskListError(message:_mapFailureToMessage(failure)),
            (task) {
              page++;
              final tasks = oldTasks;//(state as TaskListLoading).oldPersonList;
              tasks.addAll(task);
              return TaskListLoaded(tasksList: tasks, changed: true, addFromMobileTemplates: addFromMobileTemplates);
            });//TaskListLoaded(tasksList: task));
*/

  }
 // Stream<TaskListState> listener(event) async*{
 //   yield TaskListError(message:"eee");
 // }
  String _mapFailureToMessage(Failure failure) {
    switch(failure.runtimeType)
    {
      case ServerFailure:
        return 'Server Failure';
      default:
        return 'Unexpected error';
    }
  }

}