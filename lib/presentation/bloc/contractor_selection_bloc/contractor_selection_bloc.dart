import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/data/models/contractor_model.dart';
import 'package:mobiforce_flutter/data/models/employee_model.dart';
import 'package:mobiforce_flutter/data/models/file_model.dart';
import 'package:mobiforce_flutter/data/models/task_comment_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/data/models/taskstatus_model.dart';
import 'package:mobiforce_flutter/data/models/template_model.dart';
import 'package:mobiforce_flutter/domain/entity/contractor_entity.dart';
import 'package:mobiforce_flutter/domain/entity/sync_status_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskfield_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';
import 'package:mobiforce_flutter/domain/entity/template_entity.dart';
import 'package:mobiforce_flutter/domain/usecases/add_picture_to_field.dart';
//import 'package:mobiforce_flutter/domain/usecases/add_picture_to_task_comment.dart';
import 'package:mobiforce_flutter/domain/usecases/add_task_comment.dart';
import 'package:mobiforce_flutter/domain/usecases/authorization_check.dart';
import 'package:mobiforce_flutter/domain/usecases/delete_picture_from_field.dart';
import 'package:mobiforce_flutter/domain/usecases/get_all_tasks.dart';
import 'package:mobiforce_flutter/domain/usecases/get_contractors.dart';
import 'package:mobiforce_flutter/domain/usecases/get_current_contractor.dart';
import 'package:mobiforce_flutter/domain/usecases/get_picture_from_camera.dart';
import 'package:mobiforce_flutter/domain/usecases/get_task_detailes.dart';
import 'package:mobiforce_flutter/domain/usecases/get_task_status_graph.dart';
import 'package:mobiforce_flutter/domain/usecases/get_task_templates.dart';
import 'package:mobiforce_flutter/domain/usecases/get_tasks_comments.dart';
import 'package:mobiforce_flutter/domain/usecases/load_file.dart';
import 'package:mobiforce_flutter/domain/usecases/set_task_field_value.dart';
import 'package:mobiforce_flutter/domain/usecases/set_task_status.dart';
import 'package:mobiforce_flutter/domain/usecases/sync_to_server.dart';
import 'package:mobiforce_flutter/domain/usecases/wait.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_template_selection_bloc/task_template_selection_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_template_selection_bloc/task_template_selection_state.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/blockSteam.dart';
//import 'package:mobiforce_flutter/domain/usecases/search_task.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_state.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_state.dart';
import 'package:path_provider/path_provider.dart';

import 'contractor_selection_event.dart';
import 'contractor_selection_state.dart';
//import 'package:dartz/dartz.dart';
// import 'equatabl'
//enum PictureSourceEnum {camera, gallery}

class ContractorSelectionBloc extends Bloc<ContractorSelectionEvent,ContractorSelectionState> {
  final GetContractors contractors;
  final GetCurrentContractor currentContractor;
  /*final GetTask taskReader;

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
  final AddTaskComment addTaskComment;*/
  //final ModelImpl m;
  //final WaitDealys10 wait10;

  //final _counterStreamController = StreamController<int>();
  //StreamSink<int> get counter_sink => _counterStreamController.sink;
// expose data from stream
//  Stream<int> get stream_counter => _counterStreamController.stream;

  int id = 0;

  ContractorSelectionBloc(

  {
/* required this.taskReader,
    required this.loadFile,
    required this.nextTaskStatusesReader,
    required this.getPictureFromCamera,
    required this.setTaskStatus,
    required this.getTaskComments,
    required this.setTaskFieldSelectionValue,
    required this.addTaskComment,
    required this.syncToServer,
    required this.addPictureToTaskField,
    required this.deletePictureToTaskField,
*/
     required this.contractors,
        required this.currentContractor,
    }
  ) : super(ContractorSelectionStateEmpty()) {

  }


  //StreamSubscription streamSubscription = MyApp.model.counterUpdates.listen((newVal) => setState(() {
  //_counter = newVal;
  //}));
  //

  @override
  Stream<ContractorSelectionState> mapEventToState(ContractorSelectionEvent event) async* {
    if(event is ReloadContractorSelection) {
      //print("start")
      yield ContractorSelectionStateLoading();
      await Future.delayed(Duration(seconds: 1));
      final faiureOrLoading = await contractors(ListContractorParams(name: "1"));
      yield faiureOrLoading.fold(
              (l) => ContractorSelectionStateFailure(),
              (r) => ContractorSelectionStateLoaded(contractors:r, id: 0, query:"", searching: false)
      );


    }
     if(event is SearchContractorSelection) {
      //print("start")
      String query=(state as ContractorSelectionStateLoaded).query;
      yield ContractorSelectionStateLoaded(contractors:[], id: 0, query:"", searching: true);
      await Future.delayed(Duration(seconds: 1));
      final faiureOrLoading = await contractors(ListContractorParams(name: event.query));
      yield faiureOrLoading.fold(
              (l) => ContractorSelectionStateFailure(),
              (r) => ContractorSelectionStateLoaded(contractors:r, id: 0, query:"", searching: false, )
      );


    }
    if(event is LoadCurrentContractor) {
      if(id==0) {
        final List<ContractorEntity> contractors = (state as ContractorSelectionStateLoaded).contractors;
        print("event.id: ${event.id}");
        yield ContractorSelectionStateLoaded(contractors:contractors, id: event.id, query: "", searching: false);
        await Future.delayed(Duration(seconds: 1));
        final faiureOrLoading = await currentContractor(ContractorParams(id: event.id));
        yield faiureOrLoading.fold(
                (l) => ContractorSelectionStateFailure(),
                (r) {
                  print("loaded contractor");
                  //return ContractorSelectionStateSelect(contractor:(r as ContractorModel));
                  return ContractorSelectionStateLoaded(contractors:contractors, id: 0, query:"", searching: true, contractor:r);
                }
        );

//        yield ContractorSelectionStateSelect(contractor:(contractors.firstWhere((element) => element.serverId==event.id) as ContractorModel));
      }
      //print("start")
      //yield TaskTemplateSelectionStateLoading();
      //await Future.delayed(Duration(seconds: 1));
      //final faiureOrLoading = await taskTemplates(ListTemplateParams(page: 1));
      //yield faiureOrLoading.fold(
      //        (l) => TaskTemplateSelectionStateFailure(),
      //        (r) => TaskTemplateSelectionStateLoaded(taskTemlates:r)
      //);


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


}
