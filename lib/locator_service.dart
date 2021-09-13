import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/core/platform/network_info.dart';
import 'package:mobiforce_flutter/data/datasources/authorization_data_sources.dart';
import 'package:mobiforce_flutter/data/datasources/authorization_remote_data_sources.dart';
import 'package:mobiforce_flutter/data/datasources/full_remote_data_sources.dart';
import 'package:mobiforce_flutter/data/datasources/task_remote_data_sources.dart';
import 'package:mobiforce_flutter/data/datasources/updates_remote_data_sources.dart';
import 'package:mobiforce_flutter/domain/repositories/authirization_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/authorization_repository_impl.dart';
import 'package:mobiforce_flutter/domain/repositories/full_sync_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/full_sync_repository_impl.dart';
import 'package:mobiforce_flutter/domain/repositories/sync_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/sync_repository_impl.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:mobiforce_flutter/domain/usecases/authorization.dart';
import 'package:mobiforce_flutter/domain/usecases/authorization_check.dart';
import 'package:mobiforce_flutter/domain/usecases/full_sync_from_server.dart';
import 'package:mobiforce_flutter/domain/usecases/get_all_tasks.dart';
import 'package:mobiforce_flutter/domain/usecases/sync_from_server.dart';
import 'package:mobiforce_flutter/presentation/bloc/login_bloc/login_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/sync_bloc/fullSyncSteam.dart';
import 'package:mobiforce_flutter/presentation/bloc/sync_bloc/sync_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/blockSteam.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_bloc.dart';
//import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasksearch_bloc/tasksearch_bloc.dart';
import 'package:mobiforce_flutter/presentation/pages/syncscreen_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'domain/repositories/task_repository_impl.dart';
import 'domain/usecases/search_task.dart';
import 'package:http/http.dart' as http;

import 'domain/usecases/wait.dart';

final sl = GetIt.instance;

Future<void>init() async
{
  //bloc
  sl.registerFactory(() => TaskSearchBloc(searchTask: sl()));
  sl.registerFactory(() => TaskListBloc(listTask: sl(),m:sl()));
  sl.registerFactory(() => LoginBloc(auth: sl()));
  sl.registerFactory(() => SyncBloc(m:sl()));


  //usecases
  sl.registerLazySingleton(() => SearchTask(sl()));
  sl.registerLazySingleton(() => GetAllTasks(sl()));
  sl.registerLazySingleton(() => SyncFromServer(sl(),sl(),sl()));
  sl.registerLazySingleton(() => FullSyncFromServer(fullSyncRepository: sl(), db:sl()));
  //sl.registerLazySingleton(() => WaitDealys10(model: sl()));
  //sl.registerLazySingleton(() => Model());
  sl.registerLazySingleton(() => Authorization(sl()));
  sl.registerLazySingleton(() => AuthorizationManager(sl()));
  //sl.registerLazySingleton(() => Model());
  //sl.registerLazySingleton(() => LoginTasks(sl()));
  //repository
  sl.registerLazySingleton<TaskRepository>(
      () => TaskRepositoryImpl(
          remoteDataSources: sl(),
          networkInfo: sl()
      )
  );

  sl.registerLazySingleton<SyncRepository>(
      () => SyncRepositoryImpl(
          updatesRemoteDataSources: sl(),
          networkInfo: sl(),
          sharedPreferences: sl()
      )
  );
  sl.registerLazySingleton<FullSyncRepository>(
      () => FullSyncRepositoryImpl(
          fullRemoteDataSources: sl(),
          networkInfo: sl(),
          sharedPreferences: sl()
      )
  );
  sl.registerLazySingleton<ModelImpl>(
      () => ModelImpl(syncFromServer:sl()
          //remoteDataSources: sl(),
          //networkInfo: sl()
      )
  );
  sl.registerLazySingleton<FullSyncImpl>(
      () => FullSyncImpl(fullSyncFromServer:sl()
          //remoteDataSources: sl(),
          //networkInfo: sl()
      )
  );
   //sl.registerLazySingleton<Model>();
  sl.registerLazySingleton<TaskRemoteDataSources>(() => TaskRemoteDataSourcesImpl(client: http.Client(),sharedPreferences: sl(),db:sl()));

  sl.registerLazySingleton<AuthorizationRepository>(
      () => AuthorizationRepositoryImpl(
          remoteDataSources: sl(),
          networkInfo: sl(),
          authorizationDataSource: sl()
      )
  );
  sl.registerLazySingleton<AuthorizationRemoteDataSources>(() => AuthorizationRemoteDataSourcesImpl(client: http.Client()));

  sl.registerLazySingleton<UpdatesRemoteDataSources>(
        () => UpdatesRemoteDataSourcesImpl(client: http.Client()),
  );
  sl.registerLazySingleton<FullRemoteDataSources>(
        () => FullRemoteDataSourcesImpl(client: http.Client()),
  );

  sl.registerLazySingleton<AuthorizationDataSource>(
        () => AuthorizationDataSourceImpl(sharedPreferences: sl()),
  );
  //core

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => DBProvider());
  //external
  final sharedPrefernces = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPrefernces);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());
}