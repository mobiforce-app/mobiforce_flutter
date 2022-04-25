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
import 'package:mobiforce_flutter/data/models/equipment_model.dart';
import 'package:mobiforce_flutter/data/models/file_model.dart';
import 'package:mobiforce_flutter/data/models/task_comment_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/data/models/taskstatus_model.dart';
import 'package:mobiforce_flutter/data/models/template_model.dart';
import 'package:mobiforce_flutter/domain/entity/equipment_entity.dart';
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
import 'package:mobiforce_flutter/domain/usecases/get_current_contractor.dart';
import 'package:mobiforce_flutter/domain/usecases/get_current_equipment.dart';
import 'package:mobiforce_flutter/domain/usecases/get_current_template.dart';
import 'package:mobiforce_flutter/domain/usecases/get_equipment.dart';
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
import 'package:mobiforce_flutter/presentation/bloc/contractor_selection_bloc/contractor_selection_state.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_equipment_selection_bloc/task_equipment_selection_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_equipment_selection_bloc/task_equipment_selection_state.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_template_selection_bloc/task_template_selection_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_template_selection_bloc/task_template_selection_state.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/blockSteam.dart';
//import 'package:mobiforce_flutter/domain/usecases/search_task.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_state.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_state.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:dartz/dartz.dart';
// import 'equatabl'
//enum PictureSourceEnum {camera, gallery}

class TaskEquipmentSelectionBloc extends Bloc<TaskEquipmentSelectionEvent,TaskEquipmentSelectionState> {
  final GetCurrentContractor currentContractor;
  final GetEquipment equipment;
  final GetCurrentEquipment currentEquipment;
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
  int? contractorServerId;
  int id = 0;

  TaskEquipmentSelectionBloc(

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
     required this.equipment,
     required this.currentContractor,
     required this.currentEquipment,
    }
  ) : super(TaskEquipmentSelectionStateEmpty()) {

  }


  //StreamSubscription streamSubscription = MyApp.model.counterUpdates.listen((newVal) => setState(() {
  //_counter = newVal;
  //}));
  //

  @override
  Stream<TaskEquipmentSelectionState> mapEventToState(TaskEquipmentSelectionEvent event) async* {
    if(event is ReloadTaskEquipmentSelection) {
      //print("start")
      contractorServerId=event.contractorServerId;
      yield TaskEquipmentSelectionStateLoading();
      await Future.delayed(Duration(seconds: 1));
      final faiureOrLoading = await equipment(ListEquipmentParams(contractor: contractorServerId));
      yield faiureOrLoading.fold(
              (l) => TaskEquipmentSelectionStateFailure(),
              (r) => TaskEquipmentSelectionStateLoaded(taskEquipments:r, id: 0, searching: false, query: "")
      );


    }
    if(event is SearchEquipmentSelection) {
      print("start");
      String query=(state as TaskEquipmentSelectionStateLoaded).query;
      yield TaskEquipmentSelectionStateLoaded(taskEquipments:[], id: 0, query:"", searching: true);
      await Future.delayed(Duration(seconds: 1));
      final faiureOrLoading = await equipment(ListEquipmentParams(query: event.query, contractor: contractorServerId));
      yield faiureOrLoading.fold(
              (l) => TaskEquipmentSelectionStateFailure(),
              (r) => TaskEquipmentSelectionStateLoaded(taskEquipments:r, id: 0, query:"", searching: false, )
      );


    }

    if(event is LoadCurrentTaskEquipment) {
/*      if(id==0) {
        final List<TemplateEntity> templates = (state as TaskTemplateSelectionStateLoaded).taskTemlates;
        print("event.id: ${event.id}");
        yield TaskTemplateSelectionStateLoaded(taskTemlates:templates, id: event.id);
        await Future.delayed(Duration(seconds: 1));

        yield TaskTemplateSelectionStateSelect(taskTemlate:(templates.firstWhere((element) => element.serverId==event.id) as TemplateModel));
      }*/
      if(id==0) {
        final List<EquipmentEntity> templates = (state as TaskEquipmentSelectionStateLoaded).taskEquipments;
        print("event.id: ${event.id}");
        yield TaskEquipmentSelectionStateLoaded(taskEquipments:templates, id: event.id, searching: true, query:"");
        await Future.delayed(Duration(seconds: 1));
        final faiureOrLoading = await currentEquipment(EquipmentParams(id: event.id));
        //event.onSuccess();
        faiureOrLoading.fold(
          (l) => TaskEquipmentSelectionStateFailure(),
          (r) async {
            print("equipment ${(r as EquipmentModel).toJson()}");
            if((r.contractor?.serverId??0)>0) {
              print("load contractor ${(r.contractor?.serverId??0)}");
              final fOL = await currentContractor(ContractorParams(id: (r.contractor?.serverId??0)));
              fOL.fold(
                      (l1) => ContractorSelectionStateFailure(),
                      (r1) {
                        r.contractor=r1 as ContractorModel;
                  }
              );
            }
            //final faiureOrLoading = await currentEquipment(EquipmentParams(id: event.id));

            print("loaded contractor");
            //return ContractorSelectionStateSelect(contractor:(r as ContractorModel));
            event.onSuccess(r);
            //return ContractorSelectionStateLoaded(contractors:contractors, id: 0, query:"", searching: true, contractor:r);
          }
        );

//        yield ContractorSelectionStateSelect(contractor:(contractors.firstWhere((element) => element.serverId==event.id) as ContractorModel));
        /*final faiureOrLoading = await currentTemplate(TemplateParams(id: event.id));
        yield faiureOrLoading.fold(
                (l) => TaskEquipmentSelectionStateFailure(),
                (r) {
              print("loaded contractor ${r.propsList.toString()}");
              //return ContractorSelectionStateSelect(contractor:(r as ContractorModel));
              return TaskEquipmentSelectionStateLoaded(taskTemlates:templates, id: 0, taskTemlate:r);
            }
        );*/

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
