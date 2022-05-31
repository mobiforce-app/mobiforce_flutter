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
//import 'package:dartz/dartz.dart';
// import 'equatabl'
class TaskListBloc extends Bloc<TaskListEvent,TaskListState>{
  final GetAllTasks listTask;
  final ModelImpl m;
  //final WaitDealys10 wait10;

  //final _counterStreamController = StreamController<int>();
  //StreamSink<int> get counter_sink => _counterStreamController.sink;
// expose data from stream
//  Stream<int> get stream_counter => _counterStreamController.stream;

  int page = 0;
  TaskListBloc({required this.listTask,required this.m}) : super(TaskListEmpty())
  {
    m.counterUpdates.listen((item){
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
    print("start");
  }


  //StreamSubscription streamSubscription = MyApp.model.counterUpdates.listen((newVal) => setState(() {
  //_counter = newVal;
  //}));
  //

  @override
  Stream<TaskListState> mapEventToState(TaskListEvent event) async* {
    print("tasklist bloc map event "+event.toString());
    if(event is StartFullSync){
      print("start sync");
      yield GoToFullSync();
      //print("start sync1");
      //yield TaskListEmpty();
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
        TaskEntity? neededTask;
        neededTask = oldTasks.firstWhereOrNull((element) => element.id == event.task.id);
        print("try to find task id ${event.task.id}");
        if(neededTask!=null) {
          print("task found!");
          int ind = oldTasks.indexOf(neededTask);
          print("task found! $ind");

          oldTasks[ind] = event.task;
          yield TaskListLoaded(tasksList: oldTasks, changed: !currentState.changed);
        }
      }


      //yield* _mapRefreshTaskToState();
    }
  }
  Stream<TaskListState> _mapRefreshTaskToState() async*{
    final currentState = state;
    page = 0;
    var oldTasks = <TaskEntity>[];
    //m.incrementCounter();
    /*if(currentState is TaskListLoaded)
    {
      oldTasks = currentState.tasksList;
    }
*/

    yield TaskListLoading(oldTasks,isFirstFetch: page==0);
    final faiureOrLoading = await listTask(ListTaskParams(page: page));

    yield faiureOrLoading.fold((failure)=>TaskListError(message:_mapFailureToMessage(failure)), (task) {
      page++;
      //final tasks = (state as TaskListLoading).oldPersonList;
      //tasks.addAll(task);
      return TaskListLoaded(tasksList: task, changed: true);
    });//TaskListLoaded(tasksList: task));


  }

  Stream<TaskListState> _mapFetchTaskToState() async*{
    final currentState = state;
    //SyncReady();
    //yield Stream.fromFutures([wait10()]).listen(listener);
    var oldTasks = <TaskEntity>[];
    if(currentState is TaskListLoaded)
    {
      oldTasks = currentState.tasksList;
    }

    yield TaskListLoading(oldTasks,isFirstFetch: page==0);
    print("page: $page");
    final faiureOrLoading = await listTask(ListTaskParams(page: page));

    yield faiureOrLoading.fold(
            (failure) => TaskListError(message:_mapFailureToMessage(failure)),
            (task) {
              page++;
              final tasks = (state as TaskListLoading).oldPersonList;
              tasks.addAll(task);
              return TaskListLoaded(tasksList: tasks, changed: true);
            });//TaskListLoaded(tasksList: task));


  }
  Stream<TaskListState> listener(event) async*{
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