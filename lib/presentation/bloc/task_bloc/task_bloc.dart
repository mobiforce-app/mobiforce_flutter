import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/domain/entity/sync_status_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/usecases/authorization_check.dart';
import 'package:mobiforce_flutter/domain/usecases/get_all_tasks.dart';
import 'package:mobiforce_flutter/domain/usecases/get_task_detailes.dart';
import 'package:mobiforce_flutter/domain/usecases/get_task_status_graph.dart';
import 'package:mobiforce_flutter/domain/usecases/set_task_status.dart';
import 'package:mobiforce_flutter/domain/usecases/wait.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/blockSteam.dart';
//import 'package:mobiforce_flutter/domain/usecases/search_task.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_state.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_state.dart';
//import 'package:dartz/dartz.dart';
// import 'equatabl'
class TaskBloc extends Bloc<TaskEvent,TaskState> {
  final GetTask task;
  final GetTaskStatusesGraph nextTaskStatuses;
  final SetTaskStatus setTaskStatus;

  //final ModelImpl m;
  //final WaitDealys10 wait10;

  //final _counterStreamController = StreamController<int>();
  //StreamSink<int> get counter_sink => _counterStreamController.sink;
// expose data from stream
//  Stream<int> get stream_counter => _counterStreamController.stream;

  int id = 0;

  TaskBloc({required this.task,required this.nextTaskStatuses,required this.setTaskStatus}) : super(TaskEmpty()) {

  }

  //m.counterUpdates.listen((item) => print(item)); // использование лямбда-функции

  //StreamSubscription streamSubscription = MyApp.model.counterUpdates.listen((newVal) => setState(() {
  //_counter = newVal;
  //}));
  //

  @override
  Stream<TaskState> mapEventToState(TaskEvent event) async* {
    print("tasklist bloc map event " + event.toString());
    if (event is ChangeTaskStatus) {
      yield StartLoadingTaskPage();
      //await Future.delayed(Duration(seconds: 2));
      print("SetTaskStatus ${event.status} ${event.task}");
      final faiureOrLoading = await setTaskStatus(SetTaskStatusParams(task: event.task,status: event.status));
      yield await faiureOrLoading.fold((failure) async =>TaskError(message:"bad"), (task) async {
        final FoL = await nextTaskStatuses(TaskStatusParams(id: task.status?.id));
        return FoL.fold((failure) =>TaskError(message:"bad"), (nextTaskStatuses) {
          //final FoL = await nextTaskStatuses(TaskStatusParams(id: task.status?.id));
          print("nextTaskStatuses = ${nextTaskStatuses.toString()}");
          return TaskLoaded(task: task, nextTaskStatuses:nextTaskStatuses);
        });
        //return TaskLoaded(task: task);
      });
    }
    if (event is ReloadTask) {
      print("start sync");
      //TaskModel t=//task.taskRepository()
      yield StartLoadingTaskPage();
      await Future.delayed(Duration(seconds: 2));
      final faiureOrLoading = await task(TaskParams(id: event.id));

      //print("start sync1");
      //yield TaskListEmpty();
      yield await faiureOrLoading.fold((failure) async =>TaskError(message:"bad"), (task) async {
        final FoL = await nextTaskStatuses(TaskStatusParams(id: task.status?.id));
        return FoL.fold((failure) =>TaskError(message:"bad"), (nextTaskStatuses) {
          //final FoL = await nextTaskStatuses(TaskStatusParams(id: task.status?.id));
          print("nextTaskStatuses = ${nextTaskStatuses.toString()}");
          return TaskLoaded(task: task, nextTaskStatuses:nextTaskStatuses);
        });
        //return TaskLoaded(task: task);
      });
    }
    /*if (event is GetTaskUpdatesFromServer) {
      //m.startUpdate();
    }
    if (event is SetEmptyList) {
      //   print("start sync");
      yield TaskListEmpty();
    }
    if (event is ListTasks) {
      yield* _mapFetchTaskToState();
    }
    if (event is BadListTasks) {
      print("wait 10 sec");
      yield TaskListError(message: "111");
    }
    else if (event is RefreshListTasks) {
      print("map event!");
      yield* _mapRefreshTaskToState();
    }*/
  }

  Stream<TaskState> _mapRefreshTaskToState() async* {
    final currentState = state;
    id = 0;
    var oldTasks = <TaskEntity>[];
    //m.incrementCounter();
    /*if(currentState is TaskListLoaded)
    {
      oldTasks = currentState.tasksList;
    }
*/

//    yield TaskListLoading(oldTasks,isFirstFetch: page==0);
    final faiureOrLoading = await task(TaskParams(id: id));

/*    yield faiureOrLoading.fold((failure)=>TaskListError(message:_mapFailureToMessage(failure)), (task) {
      page++;
      //final tasks = (state as TaskListLoading).oldPersonList;
      //tasks.addAll(task);
      return TaskListLoaded(tasksList: task);
    });//TaskListLoaded(tasksList: task));
*/

  }
}
/*
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

}*/