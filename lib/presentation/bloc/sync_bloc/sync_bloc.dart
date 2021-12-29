import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobiforce_flutter/domain/usecases/authorization.dart';
import 'package:mobiforce_flutter/domain/usecases/authorization_check.dart';
import 'package:mobiforce_flutter/presentation/bloc/sync_bloc/fullSyncSteam.dart';
import 'package:mobiforce_flutter/presentation/bloc/sync_bloc/sync_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/sync_bloc/sync_state.dart';
//import 'package:mobiforce_flutter/core/error/failure.dart';
//import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
//import 'package:mobiforce_flutter/domain/usecases/get_all_tasks.dart';
//import 'package:mobiforce_flutter/domain/usecases/search_task.dart';
//import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_event.dart';
//import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_state.dart';
//import 'package:dartz/dartz.dart';
// import 'equatabl'
class SyncBloc extends Bloc<SyncEvent,SyncState>{
  final FullSyncImpl m;
  bool listenerIsInit=false;
  //final Authorization auth;
  //final GetAllTasks listTask;
  //int page = 1;
  //int lastUpdateCount;
  //int lastSyncTime;

  SyncBloc({required this.m}) : super(SyncOK())
  {
  }

  //

  @override
  Stream<SyncState> mapEventToState(SyncEvent event) async* {
    print("map event+ ${event}");
    if(event is TryToSync) {
      yield SyncWaitingServerAnswer();
    }
    else if(event is FullSyncingStart){
      yield StartFullSyncWindow();
      print("wait");
      //await Future.delayed(Duration(seconds: ));
      //print("listenerIsInit $listenerIsInit");
      if(!m.hasListener) {
        //listenerIsInit=true;
        //print("listenerIsInit $listenerIsInit");

        m.counterUpdates.listen((item) {
          print(item.progress);
          if (item.error!=null)
            this.add(FullSyncingError());
          else if (item.complete)
            this.add(FullSyncingComplete());
          else
            this.add(FullSyncingInProgress(progress:item.progress,objectTypeName: item.syncNameStr));
        });

      }

      print("start full exchange");

      m.startUpdate();
      //yield CloseFullSyncWindow();
    }
    else if(event is FullSyncingReStart){
      m.startUpdate();
      //yield CloseFullSyncWindow();
    }
    else if(event is FullSyncingComplete){
      yield CloseFullSyncWindow();
    }
    else if(event is FullSyncingError){
      print("error ErrorFullSyncWindow");
      yield ErrorFullSyncWindow();
    }
    else if(event is ReadyToSync){
      yield SyncOK();
    }
    else if(event is FullSyncingInProgress){
      print ("event progress=${event.progress.toDouble()}");
      //if(event.progress%20==0)
        yield SyncInProgress(progress: event.progress.toDouble(),objectTypeName: event.objectTypeName);
      //else
        //yield SyncWaitingServerAnswer();
    }
    //yield* _mapRefreshTaskToState();
    /*if(event is ListTasks){
      yield* _mapFetchTaskToState();
    }
    else if(event is RefreshListTasks){
      print("map event!");
      yield* _mapRefreshTaskToState();
    }*/
  }
  Stream<SyncState> _mapRefreshTaskToState() async*{
    //final currentState = state;
    //page = 1;
    //var oldTasks = <TaskEntity>[];
    /*if(currentState is TaskListLoaded)
    {
      oldTasks = currentState.tasksList;
    }

    //yield TaskListLoading(oldTasks,isFirstFetch: page==1);
    final faiureOrLoading = await listTask(ListTaskParams(page: page));

    yield faiureOrLoading.fold((failure)=>TaskListError(message:_mapFailureToMessage(failure)), (task) {
      page++;
      //final tasks = (state as TaskListLoading).oldPersonList;
      //tasks.addAll(task);
      return TaskListLoaded(tasksList: task);
    });//TaskListLoaded(tasksList: task));
    */

  }
/*
  Stream<TaskListState> _mapFetchTaskToState() async*{
    final currentState = state;

    var oldTasks = <TaskEntity>[];
    if(currentState is TaskListLoaded)
    {
      oldTasks = currentState.tasksList;
    }

    yield TaskListLoading(oldTasks,isFirstFetch: page==1);
    final faiureOrLoading = await listTask(ListTaskParams(page: page));

    yield faiureOrLoading.fold((failure)=>TaskListError(message:_mapFailureToMessage(failure)), (task) {
      page++;
      final tasks = (state as TaskListLoading).oldPersonList;
      tasks.addAll(task);
      return TaskListLoaded(tasksList: tasks);
    });//TaskListLoaded(tasksList: task));


  }
*/
  /*String _mapFailureToMessage(Failure failure) {
    switch(failure.runtimeType)
    {
      case ServerFailure:
        return 'Server Failure';
      default:
        return 'Unexpected error';
    }
  }
*/
}