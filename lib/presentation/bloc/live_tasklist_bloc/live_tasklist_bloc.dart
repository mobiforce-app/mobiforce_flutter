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
import 'package:mobiforce_flutter/presentation/bloc/live_tasklist_bloc/live_tasklist_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/live_tasklist_bloc/live_tasklist_state.dart';
import 'package:collection/collection.dart';

import '../../../domain/usecases/SendGeoLog.dart';
import '../../../domain/usecases/get_live_tasks.dart';
import '../../../domain/usecases/get_task_templates.dart';
import '../../../domain/usecases/start_geolocation_service.dart';
//import 'package:dartz/dartz.dart';
// import 'equatabl'
class LiveTaskListBloc extends Bloc<LiveTaskListEvent,LiveTaskListState>{
  final GetLiveTasks listLiveTask;
  final GetTaskTemplates taskTemplatesList;
  final StartGeolocationService startGeolocationService;
  final SendGeoLog geoLogSender;
  //final WaitDealys10 wait10;

  //final _counterStreamController = StreamController<int>();
  //StreamSink<int> get counter_sink => _counterStreamController.sink;
// expose data from stream
//  Stream<int> get stream_counter => _counterStreamController.stream;

  int page = 0;
  LiveTaskListBloc({required this.listLiveTask,required this.taskTemplatesList,required this.startGeolocationService,required this.geoLogSender}) : super(TaskListEmpty())
  {

    print("start");
  }


  //StreamSubscription streamSubscription = MyApp.model.counterUpdates.listen((newVal) => setState(() {
  //_counter = newVal;
  //}));
  //

  @override
  Stream<LiveTaskListState> mapEventToState(LiveTaskListEvent event) async* {
    print("tasklist bloc map event "+event.toString());
    if(event is ReloadLiveTasksList){
      print("start sync");
      yield ReloadingLiveTasksList();
      page = 0;
      final faiureOrLoading = await listLiveTask(LiveListTaskParams(page: page));
      yield faiureOrLoading.fold((failure)=>TaskListError(message:_mapFailureToMessage(failure)), (liveTask) {
        page++;
        //final tasks = (state as TaskListLoading).oldPersonList;
        //tasks.addAll(task);
        return LiveTaskListLoaded(tasksList: liveTask, changed: true);
      });
      //yield GoToFullSync();
      //print("start sync1");
      //yield TaskListEmpty();
    }
    /*
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

    }
    if(event is SetEmptyList){
    //   print("start sync");
      yield TaskListEmpty();
    }
    if(event is ReloadTasks){
      page = 0;
      final currentState = state;
      int addFromMobileTemplates = 0;
      if(currentState is TaskListLoaded)
      {
        addFromMobileTemplates = currentState.addFromMobileTemplates;
      }

      yield TaskListLoading([],isFirstFetch: page==0);
      final faiureOrLoading = await listTask(ListTaskParams(page: page));

      yield faiureOrLoading.fold((failure)=>TaskListError(message:_mapFailureToMessage(failure)), (task) {
        page++;
        //final tasks = (state as TaskListLoading).oldPersonList;
        //tasks.addAll(task);
        return TaskListLoaded(tasksList: task, changed: true, addFromMobileTemplates: addFromMobileTemplates);
      });//TaskListLoaded(tasksList: task));

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


      //yield* _mapRefreshTaskToState();
    }*/
  }
  Stream<LiveTaskListState> _mapRefreshTaskToState() async*{
    final currentState = state;
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
    final faiureOrLoading = await listLiveTask(LiveListTaskParams(page: page));

    // yield faiureOrLoading.fold((failure)=>TaskListError(message:_mapFailureToMessage(failure)), (task) {
    //   page++;
    //   //final tasks = (state as TaskListLoading).oldPersonList;
    //   //tasks.addAll(task);
    //   return TaskListLoaded(tasksList: task, changed: true, addFromMobileTemplates: addFromMobileTemplates);
    // });//TaskListLoaded(tasksList: task));


  }

  Stream<LiveTaskListState> _mapFetchTaskToState() async*{
    final currentState = state;
    //SyncReady();
    //yield Stream.fromFutures([wait10()]).listen(listener);
    var oldTasks = <TaskEntity>[];
    int addFromMobileTemplates = 0;
    // if(currentState is TaskListLoaded)
    // {
    //   oldTasks = currentState.tasksList;
    //   addFromMobileTemplates = currentState.addFromMobileTemplates;
    // }

    yield TaskListLoading(oldTasks,isFirstFetch: page==0);
    print("page: $page");
    final faiureOrLoading = await listLiveTask(LiveListTaskParams(page: page));
    //yield TaskListLoaded(tasksList: oldTasks, changed: true, addFromMobileTemplates: addFromMobileTemplates);

    // yield faiureOrLoading.fold(
    //         (failure) => TaskListError(message:_mapFailureToMessage(failure)),
    //         (task) {
    //           page++;
    //           final tasks = oldTasks;//(state as TaskListLoading).oldPersonList;
    //           tasks.addAll(task);
    //           return TaskListLoaded(tasksList: tasks, changed: true, addFromMobileTemplates: addFromMobileTemplates);
    //         });//TaskListLoaded(tasksList: task));


  }
  Stream<LiveTaskListState> listener(event) async*{
    yield TaskListError(message:"eee");
  }
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