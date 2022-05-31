import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobiforce_flutter/domain/repositories/firebase.dart';
import 'package:mobiforce_flutter/domain/usecases/authorization.dart';
import 'package:mobiforce_flutter/domain/usecases/authorization_check.dart';
import 'package:mobiforce_flutter/presentation/bloc/login_bloc/login_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/login_bloc/login_state.dart';

import '../../../domain/usecases/user_logout.dart';
//import 'package:mobiforce_flutter/core/error/failure.dart';
//import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
//import 'package:mobiforce_flutter/domain/usecases/get_all_tasks.dart';
//import 'package:mobiforce_flutter/domain/usecases/search_task.dart';
//import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_event.dart';
//import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_state.dart';
//import 'package:dartz/dartz.dart';
// import 'equatabl'
class LoginBloc extends Bloc<LoginEvent,LoginState>{
  final Authorization auth;
  final UserLogout logout;
  final PushNotificationService fcm;
  //final GetAllTasks listTask;
  //int page = 1;
  LoginBloc({required this.auth, required this.fcm, required this.logout}) : super(LoginReady());

  //

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    print("map event+");
    if(event is TryToLogin) {
      yield LoginWaitingServerAnswer();
      print("fcmToken: ${fcm.token}");
      final int start = event.domain.indexOf("://");
      String domain = start>=0?event.domain.substring(start+3):event.domain;
      final int finish = domain.indexOf(".");
      domain = finish>=0?domain.substring(0,finish):event.domain;
      print("domain: $domain");
      final faiureOrLoading = await auth(AuthorizationParams(
          domain: domain.trim(),
          fcmToken: fcm.token,
          login:  event.login,
          pass:  event.pass.trim()));
      //await Future.delayed(Duration(seconds: 2));
      yield faiureOrLoading.fold((failure) => LoginError(message: "ошибка авторизации"), (task) {
        return LoginOK();
      });
    }
    if(event is Logout) {

      print("event Logout");
      yield LogoutStart();
      event.callback();
      //await Future.delayed(Duration(seconds: 2));
      final faiureOrLoading = await logout(UserLogoutParams());
      //await Future.delayed(Duration(seconds: 2));
      yield faiureOrLoading.fold((failure) => LoginError(message: "ошибка авторизации"), (task) {
        return LoginReady();
      });

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
  Stream<LoginState> _mapRefreshTaskToState() async*{
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