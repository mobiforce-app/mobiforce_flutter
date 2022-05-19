import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/data/models/employee_model.dart';
import 'package:mobiforce_flutter/data/models/file_model.dart';
import 'package:mobiforce_flutter/data/models/person_model.dart';
import 'package:mobiforce_flutter/data/models/phone_model.dart';
import 'package:mobiforce_flutter/data/models/task_comment_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/data/models/taskstatus_model.dart';
import 'package:mobiforce_flutter/domain/entity/employee_entity.dart';
import 'package:mobiforce_flutter/domain/entity/phone_entity.dart';
import 'package:mobiforce_flutter/domain/entity/sync_status_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_life_cycle_node_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskfield_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';
import 'package:mobiforce_flutter/domain/usecases/add_new_phone.dart';
import 'package:mobiforce_flutter/domain/usecases/add_picture_to_field.dart';
//import 'package:mobiforce_flutter/domain/usecases/add_picture_to_task_comment.dart';
import 'package:mobiforce_flutter/domain/usecases/add_task_comment.dart';
import 'package:mobiforce_flutter/domain/usecases/authorization_check.dart';
import 'package:mobiforce_flutter/domain/usecases/delete_picture_from_field.dart';
import 'package:mobiforce_flutter/domain/usecases/get_all_tasks.dart';
import 'package:mobiforce_flutter/domain/usecases/get_new_task_number.dart';
import 'package:mobiforce_flutter/domain/usecases/get_picture_from_camera.dart';
import 'package:mobiforce_flutter/domain/usecases/get_task_detailes.dart';
import 'package:mobiforce_flutter/domain/usecases/get_task_status_graph.dart';
import 'package:mobiforce_flutter/domain/usecases/get_tasks_comments.dart';
import 'package:mobiforce_flutter/domain/usecases/load_file.dart';
import 'package:mobiforce_flutter/domain/usecases/save_new_task.dart';
import 'package:mobiforce_flutter/domain/usecases/set_task_field_value.dart';
import 'package:mobiforce_flutter/domain/usecases/set_task_status.dart';
import 'package:mobiforce_flutter/domain/usecases/sync_to_server.dart';
import 'package:mobiforce_flutter/domain/usecases/wait.dart';
import 'package:mobiforce_flutter/presentation/bloc/setting_bloc/setting_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/setting_bloc/setting_state.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/blockSteam.dart';
//import 'package:mobiforce_flutter/domain/usecases/search_task.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_state.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:collection/collection.dart';//import 'package:dartz/dartz.dart';
import 'package:mobiforce_flutter/locator_service.dart' as di;

import '../../../domain/usecases/get_user_setting.dart';
import '../../../main.dart';
// import 'equatabl'
//enum PictureSourceEnum {camera, gallery}

class SettingBloc extends Bloc<SettingEvent,SettingState> {
//  final GlobalKey<NavigatorState> navigatorKey;
  final GetUserSetting settingsReader;
/*  final GetTask taskReader;
  final CreateTaskOnServer createTaskOnServer;
  //TaskEntity? task;
  //List<TaskStatusEntity>? nextTaskStatuses;
  final GetPictureFromCamera getPictureFromCamera;
  final LoadFile loadFile;
  final AddPictureToTaskField addPictureToTaskField;
  final DeletePictureToTaskField deletePictureToTaskField;
  //final AddCommentWithPictureToTask addCommentWithPictureToTask;
  final GetTaskStatusesGraph nextTaskStatusesReader;
  final SetTaskStatus setTaskStatus;
  final SetTaskFieldSelectionValue setTaskFieldSelectionValue;
  final SyncToServer syncToServer;
  final GetTaskComments getTaskComments;
  final AddTaskComment addTaskComment;
  final SaveNewTask saveNewTask;
  final AddNewPhone addNewPhone;
*/  //final ModelImpl m;
  //final WaitDealys10 wait10;

  //final _counterStreamController = StreamController<int>();
  //StreamSink<int> get counter_sink => _counterStreamController.sink;
// expose data from stream
//  Stream<int> get stream_counter => _counterStreamController.stream;

  int id = 0;

  SettingBloc({required this.settingsReader}) : super(SettingEmpty()) {

  }


  //StreamSubscription streamSubscription = MyApp.model.counterUpdates.listen((newVal) => setState(() {
  //_counter = newVal;
  //}));
  //

  @override
  Stream<SettingState> mapEventToState(SettingEvent event) async* {
    print("tasklist bloc map event " + event.toString()+ " ${state.runtimeType }");
    if (event is ReloadSetting) {
      print("start sync");
      //TaskModel t=//task.taskRepository()
      //yield StartLoadingTaskPage();
      //Directory dir =  await getApplicationDocumentsDirectory();

      // await Future.delayed(Duration(seconds: 2));
      final faiureOrLoading = await settingsReader(UserSettingParams(id:0));
      yield faiureOrLoading.fold((failure)=>SettingEmpty(), (settings) {
        //page++;
        //final tasks = (state as TaskListLoading).oldPersonList;
        //tasks.addAll(task);
        print(settings.toString());
        return SettingLoaded(settings);
      });
      //print("start sync1");

        //return TaskLoaded(task: task);
      //});
    }

  }


}
