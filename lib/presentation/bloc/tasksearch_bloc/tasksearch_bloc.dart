import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/domain/usecases/search_task.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasksearch_bloc/tasksearch_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasksearch_bloc/tasksearch_state.dart';
//import 'package:dartz/dartz.dart';
// import 'equatabl'

class TaskSearchBloc extends Bloc<TaskSearchEvent,TaskSearchState>{
  final SearchTask searchTask;

  TaskSearchBloc({required this.searchTask}) : super(TaskEmpty());

  @override
  Stream<TaskSearchState> mapEventToState(TaskSearchEvent event) async* {
    if(event is SearchTasks){
      yield* _mapFetchTaskToState(event.taskQuery);
    }
  }
  Stream<TaskSearchState> _mapFetchTaskToState(String taskQuery) async*{
    yield TaskSearchLoading();
    final faiureOrLoading = await searchTask(SearchTaskParams(query: taskQuery));

    yield faiureOrLoading.fold((failure)=>TaskSearchError(message:_mapFailureToMessage(failure)), (task)=>TaskSearchLoaded(tasks: task));
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