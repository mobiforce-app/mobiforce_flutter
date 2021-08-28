import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/usecases/get_all_tasks.dart';
//import 'package:mobiforce_flutter/domain/usecases/search_task.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_state.dart';
//import 'package:dartz/dartz.dart';
// import 'equatabl'
class TaskListBloc extends Bloc<TaskListEvent,TaskListState>{
  final GetAllTasks listTask;
  int page = 1;
  TaskListBloc({required this.listTask}) : super(TaskListEmpty());

  //

  @override
  Stream<TaskListState> mapEventToState(TaskListEvent event) async* {
    print("map event");
    if(event is ListTasks){
      yield* _mapFetchTaskToState();
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
    /*if(currentState is TaskListLoaded)
    {
      oldTasks = currentState.tasksList;
    }
*/
    yield TaskListLoading(oldTasks,isFirstFetch: page==1);
    final faiureOrLoading = await listTask(ListTaskParams(page: page));

    yield faiureOrLoading.fold((failure)=>TaskListError(message:_mapFailureToMessage(failure)), (task) {
      page++;
      final tasks = (state as TaskListLoading).oldPersonList;
      tasks.addAll(task);
      return TaskListLoaded(tasksList: tasks);
    });//TaskListLoaded(tasksList: task));


  }

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