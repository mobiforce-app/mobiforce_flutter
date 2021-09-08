import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/usecases/authorization_check.dart';
import 'package:mobiforce_flutter/domain/usecases/get_all_tasks.dart';
import 'package:mobiforce_flutter/domain/usecases/wait.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/blockSteam.dart';
//import 'package:mobiforce_flutter/domain/usecases/search_task.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_state.dart';
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

  int page = 1;
  TaskListBloc({required this.listTask,required this.m}) : super(TaskListEmpty())
  {
    m.counterUpdates.listen((item){
      print(item.progress);
      this.add(FullSyncTasks());
    });
    m.startUpdate();
    print("start");
  }

  //m.counterUpdates.listen((item) => print(item)); // использование лямбда-функции

  //StreamSubscription streamSubscription = MyApp.model.counterUpdates.listen((newVal) => setState(() {
  //_counter = newVal;
  //}));
  //

  @override
  Stream<TaskListState> mapEventToState(TaskListEvent event) async* {
    print("tasklist bloc map event "+event.toString());
    if(event is FullSyncTasks){
      print("start sync");
      yield GoToFullSync();
      //print("start sync1");
      //yield TaskListEmpty();
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
  }
  Stream<TaskListState> _mapRefreshTaskToState() async*{
    final currentState = state;
    page = 1;
    var oldTasks = <TaskEntity>[];
    //m.incrementCounter();
    /*if(currentState is TaskListLoaded)
    {
      oldTasks = currentState.tasksList;
    }
*/

    yield TaskListLoading(oldTasks,isFirstFetch: page==1);
    final faiureOrLoading = await listTask(ListTaskParams(page: page));

    yield faiureOrLoading.fold((failure)=>TaskListError(message:_mapFailureToMessage(failure)), (task) {
      page++;
      //final tasks = (state as TaskListLoading).oldPersonList;
      //tasks.addAll(task);
      return TaskListLoaded(tasksList: task);
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

    yield TaskListLoading(oldTasks,isFirstFetch: page==1);
    print("page: $page");
    final faiureOrLoading = await listTask(ListTaskParams(page: page));

    yield faiureOrLoading.fold(
            (failure) => TaskListError(message:_mapFailureToMessage(failure)),
            (task) {
              page++;
              final tasks = (state as TaskListLoading).oldPersonList;
              tasks.addAll(task);
              return TaskListLoaded(tasksList: tasks);
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