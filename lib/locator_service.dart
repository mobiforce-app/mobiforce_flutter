import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
import 'package:mobiforce_flutter/domain/repositories/picture_repository_impl.dart';
import 'package:mobiforce_flutter/domain/repositories/sync_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/sync_repository_impl.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/template_repository.dart';
import 'package:mobiforce_flutter/domain/usecases/authorization.dart';
import 'package:mobiforce_flutter/domain/usecases/authorization_check.dart';
import 'package:mobiforce_flutter/domain/usecases/delete_picture_from_field.dart';
import 'package:mobiforce_flutter/domain/usecases/full_sync_from_server.dart';
import 'package:mobiforce_flutter/domain/usecases/get_all_tasks.dart';
import 'package:mobiforce_flutter/domain/usecases/get_current_equipment.dart';
import 'package:mobiforce_flutter/domain/usecases/get_equipment.dart';
import 'package:mobiforce_flutter/domain/usecases/get_picture_from_camera.dart';
import 'package:mobiforce_flutter/domain/usecases/get_task_detailes.dart';
import 'package:mobiforce_flutter/domain/usecases/get_task_templates.dart';
import 'package:mobiforce_flutter/domain/usecases/load_file.dart';
import 'package:mobiforce_flutter/domain/usecases/set_task_field_value.dart';
import 'package:mobiforce_flutter/domain/usecases/set_task_status.dart';
import 'package:mobiforce_flutter/domain/usecases/sync_from_server.dart';
import 'package:mobiforce_flutter/domain/usecases/user_logout.dart';
import 'package:mobiforce_flutter/main.dart';
import 'package:mobiforce_flutter/presentation/bloc/contractor_selection_bloc/contractor_selection_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/login_bloc/login_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/setting_bloc/setting_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/sync_bloc/fullSyncSteam.dart';
import 'package:mobiforce_flutter/presentation/bloc/sync_bloc/sync_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_equipment_selection_bloc/task_equipment_selection_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_template_selection_bloc/task_template_selection_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/blockSteam.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_bloc.dart';
//import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasksearch_bloc/tasksearch_bloc.dart';
import 'package:mobiforce_flutter/presentation/pages/signature_screen.dart';
import 'package:mobiforce_flutter/presentation/pages/syncscreen_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasources/online_remote_data_sources.dart';
import 'domain/repositories/firebase.dart';
import 'domain/repositories/picture_repository.dart';
import 'domain/repositories/task_repository_impl.dart';
import 'domain/repositories/template_repository_impl.dart';
import 'domain/usecases/add_new_phone.dart';
import 'domain/usecases/add_picture_to_field.dart';
//import 'domain/usecases/add_picture_to_task_comment.dart';
import 'domain/usecases/add_task_comment.dart';
import 'domain/usecases/get_contractors.dart';
import 'domain/usecases/get_current_contractor.dart';
import 'domain/usecases/get_current_template.dart';
import 'domain/usecases/get_new_task_number.dart';
import 'domain/usecases/get_task_status_graph.dart';
import 'domain/usecases/get_tasks_comments.dart';
import 'domain/usecases/get_user_setting.dart';
import 'domain/usecases/save_new_task.dart';
import 'domain/usecases/search_task.dart';
import 'package:http/http.dart' as http;

import 'domain/usecases/sync_to_server.dart';
import 'domain/usecases/wait.dart';

final sl = GetIt.instance;

Future<void>init() async
{
  //bloc
  sl.registerFactory(() => TaskSearchBloc(searchTask: sl()));
  sl.registerFactory(() => TaskListBloc(listTask: sl(),m:sl()));
  sl.registerFactory(() => SettingBloc(settingsReader: sl()));
  sl.registerFactory(() => TaskTemplateSelectionBloc(taskTemplates: sl(),currentTemplate: sl()));
  sl.registerFactory(() => TaskEquipmentSelectionBloc(equipment: sl(),currentEquipment: sl(),currentContractor: sl()));
  sl.registerFactory(() => ContractorSelectionBloc(contractors: sl(),currentContractor: sl()));
  sl.registerFactory(() => LoginBloc(auth: sl(), fcm: sl(), logout: sl()));
  //sl.registerFactory(() => SignaturePage();
  sl.registerFactory(() => SyncBloc(m:sl()));
  sl.registerFactory(() => TaskBloc(
      taskReader:sl(),
      loadFile:sl(),
      nextTaskStatusesReader: sl(),
      setTaskStatus: sl(),
      getTaskComments: sl(),
      setTaskFieldSelectionValue:sl(),
      syncToServer: sl(),
      getPictureFromCamera:sl(),
      addTaskComment:sl(),
      addPictureToTaskField: sl(),
      deletePictureToTaskField: sl(),
      saveNewTask:sl(),
      createTaskOnServer: sl(),
      addNewPhone: sl(),
//      navigatorKey: sl()
    ));


  //usecases
  sl.registerLazySingleton(() => CreateTaskOnServer(sl()));
  sl.registerLazySingleton(() => SaveNewTask(sl()));
  sl.registerLazySingleton(() => AddNewPhone(taskRepository:sl()));
  sl.registerLazySingleton(() => GetTaskTemplates(sl()));
  sl.registerLazySingleton(() => GetContractors(sl()));
  sl.registerLazySingleton(() => GetCurrentContractor(sl()));
  sl.registerLazySingleton(() => GetEquipment(sl()));
  sl.registerLazySingleton(() => GetCurrentEquipment(sl()));
  sl.registerLazySingleton(() => GetCurrentTemplate(sl()));
  sl.registerLazySingleton(() => GetPictureFromCamera(fileRepository: sl()));
  sl.registerLazySingleton(() => AddPictureToTaskField(taskRepository: sl()));
  sl.registerLazySingleton(() => DeletePictureToTaskField(taskRepository: sl()));
  //sl.registerLazySingleton(() => AddCommentWithPictureToTask(taskRepository: sl()));
  sl.registerLazySingleton(() => SearchTask(sl()));
  sl.registerLazySingleton(() => AddTaskComment(sl()));
  sl.registerLazySingleton(() => GetAllTasks(sl()));
  sl.registerLazySingleton(() => GetUserSetting(sl()));
  sl.registerLazySingleton(() => GetTask(sl()));
  sl.registerLazySingleton(() => LoadFile(fileRepository:sl()));
  sl.registerLazySingleton(() => GetTaskComments(sl()));
  sl.registerLazySingleton(() => SetTaskStatus(sl()));
  sl.registerLazySingleton(() => SetTaskFieldSelectionValue(sl()));
  sl.registerLazySingleton(() => GetTaskStatusesGraph(sl()));
  sl.registerLazySingleton(() => SyncFromServer(sl(),sl(),sl()));
  sl.registerLazySingleton(() => SyncToServer(sl(),sl()));
  sl.registerLazySingleton(() => FullSyncFromServer(fullSyncRepository: sl(), syncRepository:sl(), db:sl()));
  //sl.registerLazySingleton(() => WaitDealys10(model: sl()));
  //sl.registerLazySingleton(() => Model());
  sl.registerLazySingleton(() => UserLogout(sl(),sl()));
  sl.registerLazySingleton(() => Authorization(sl(),sl()));
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
  sl.registerLazySingleton<TemplateRepository>(
      () => TemplateRepositoryImpl(
          remoteDataSources: sl(),
          networkInfo: sl()
      )
  );
  sl.registerLazySingleton<FileRepository>(
      () => FileRepositoryImpl(
          remoteDataSources: sl(),
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
      () => ModelImpl(syncFromServer:sl(),syncToServer:sl(),
          fcm: sl(),
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
  sl.registerLazySingleton<OnlineRemoteDataSources>(() => OnlineRemoteDataSourcesImpl(client: http.Client(),sharedPreferences: sl(),db:sl()));

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
        () => AuthorizationDataSourceImpl(sharedPreferences: sl(),db: sl(),),
  );
  //core

  sl.registerLazySingleton<PushNotificationService>(() => PushNotificationService());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => DBProvider());
  //external
  final sharedPrefernces = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPrefernces);
  //final sharedPrefernces = await SharedPreferences.getInstance();
  //sl.registerLazySingleton(() => sharedPrefernces);
  //sl.registerLazySingleton(() => PushNotificationService());
  sl.registerLazySingleton(() => http.Client());
  //sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());
  //final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();
  //sl.registerLazySingleton(() => _navigatorKey);
  sl.registerLazySingleton(() => NavigationService());
}