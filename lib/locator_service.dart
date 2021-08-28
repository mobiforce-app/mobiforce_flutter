import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mobiforce_flutter/core/platform/network_info.dart';
import 'package:mobiforce_flutter/data/datasources/task_remote_data_sources.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:mobiforce_flutter/domain/usecases/get_all_tasks.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_bloc.dart';
//import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasksearch_bloc/tasksearch_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'domain/repositories/task_repository_impl.dart';
import 'domain/usecases/search_task.dart';
import 'package:http/http.dart' as http;

final sl = GetIt.instance;

Future<void>init() async
{
  //bloc
  sl.registerFactory(() => TaskSearchBloc(searchTask: sl()));
  sl.registerFactory(() => TaskListBloc(listTask: sl()));
  //usecases
  sl.registerLazySingleton(() => SearchTask(sl()));
  sl.registerLazySingleton(() => GetAllTasks(sl()));
  //repository
  sl.registerLazySingleton<TaskRepository>(
      () => TaskRepositoryImpl(
          remoteDataSources: sl(),
          networkInfo: sl()
      )
  );
  sl.registerLazySingleton<TaskRemoteDataSources>(() => TaskRemoteDataSourcesImpl(client: http.Client()));
  //core

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  //external
  final sharedPrefernces = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPrefernces);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());
}