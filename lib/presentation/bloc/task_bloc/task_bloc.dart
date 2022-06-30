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
import 'package:mobiforce_flutter/data/models/task.dart';
import 'package:mobiforce_flutter/data/models/task_comment_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/data/models/taskstatus_model.dart';
import 'package:mobiforce_flutter/domain/entity/employee_entity.dart';
import 'package:mobiforce_flutter/domain/entity/phone_entity.dart';
import 'package:mobiforce_flutter/domain/entity/sync_status_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_comment_entity.dart';
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
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/blockSteam.dart';
//import 'package:mobiforce_flutter/domain/usecases/search_task.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_state.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_state.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:collection/collection.dart';//import 'package:dartz/dartz.dart';
import 'package:mobiforce_flutter/locator_service.dart' as di;

import '../../../domain/usecases/load_task.dart';
import '../../../domain/usecases/save_file_decription.dart';
import '../../../domain/usecases/set_tasks_comments_read.dart';
import '../../../main.dart';
// import 'equatabl'
//enum PictureSourceEnum {camera, gallery}

class TaskBloc extends Bloc<TaskEvent,TaskState> {
//  final GlobalKey<NavigatorState> navigatorKey;
  final GetTask taskReader;
  final SaveFileDescription fileDescriptionSaver;
  final CreateTaskOnServer createTaskOnServer;
  //TaskEntity? task;
  //List<TaskStatusEntity>? nextTaskStatuses;
  final GetPictureFromCamera getPictureFromCamera;
  final LoadFile loadFile;
  final LoadTask loadTask;
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
  final SetTaskCommentsRead setTaskCommentsRead;
  //final ModelImpl m;
  //final WaitDealys10 wait10;

  //final _counterStreamController = StreamController<int>();
  //StreamSink<int> get counter_sink => _counterStreamController.sink;
// expose data from stream
//  Stream<int> get stream_counter => _counterStreamController.stream;

  int id = 0;

  TaskBloc({
    required this.taskReader,
    required this.saveNewTask,
    required this.loadFile,
    required this.loadTask,
    required this.nextTaskStatusesReader,
    required this.getPictureFromCamera,
    required this.setTaskStatus,
    required this.getTaskComments,
    required this.setTaskFieldSelectionValue,
    required this.addTaskComment,
    required this.syncToServer,
    required this.addPictureToTaskField,
    required this.deletePictureToTaskField,
    required this.createTaskOnServer,
    required this.addNewPhone,
    required this.fileDescriptionSaver,
    required this.setTaskCommentsRead,
//    required this.navigatorKey,
   // required this.addCommentWithPictureToTask,
  }) : super(TaskEmpty()) {

  }


  //StreamSubscription streamSubscription = MyApp.model.counterUpdates.listen((newVal) => setState(() {
  //_counter = newVal;
  //}));
  //

  @override
  Stream<TaskState> mapEventToState(TaskEvent event) async* {
    print("task bloc map event " + event.toString()+ " ${state.runtimeType }");
    if (event is ShowTaskComment&&(state.runtimeType == TaskLoaded)){
      final task = (state as TaskLoaded).task;
      final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
      final dir =  (state as TaskLoaded).appFilesDirectory;
      final isChanged=!(state as TaskLoaded).isChanged;
      final comments=(state as TaskLoaded).comments;
      print("(state as TaskLoaded).comments ${(state as TaskLoaded).comments}");
      //yield StartLoadingTaskPage();
      //if(comments.length==0) {
         final FoL = await getTaskComments(
             GetTaskCommentsParams
               (task: task.id, page: 0));
        //await await Future.delayed(Duration(seconds: 2));
        var y = FoL.fold((failure) => TaskError(message: "bad"), (newComments) {
          print("TaskLoaded ${newComments.length} ${comments.length}");

          if(newComments.length!=comments.length) {

            print("reload");
            return TaskLoaded(
              isChanged: isChanged,
              task: task,
              needToUpdateTaskList: false,
              nextTaskStatuses: nextTaskStatuses,
              appFilesDirectory: dir,
              comments: newComments,
              showCommentTab: false,
            );
          }
          else return null;

        });
        if(y!=null)
          yield y;
        FoL.fold((failure) => TaskError(message: "bad"), (newComments) async {
          print("set read");
          List<TaskCommentEntity?> unreaderComments = newComments.map((e) {
            if(e.readedTime==null) {
                TaskCommentEntity out= new TaskCommentEntity(
                    id: e.id,
                    localUsn: e.localUsn,
                    mobile: e.mobile,
                    usn: e.usn,
                    task: e.task,
                    createdTime: e.createdTime,
                    dirty: e.dirty,
                    serverId: e.serverId,
                    readedTime:
                        (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).toInt());

                return out;
              }
              else
               return null;
            }).toList();
            final FoL1 = await setTaskCommentsRead(
                SetTaskCommentsReadParams
                  (comments:unreaderComments));

            FoL1.fold((failure) => TaskError(message: "bad"), (newComments) {
              event.callback(task);
              syncToServer(ListSyncToServerParams());
            });
        });


      //}
      /*else
        {
          print("TaskLoaded comments");

          yield TaskLoaded(isChanged: isChanged,
              task: task,
              needToUpdateTaskList: false,
              nextTaskStatuses: nextTaskStatuses,
              appFilesDirectory: dir,
              comments: comments,
              showCommentTab:false,
            );
        }*/
    }
    if (event is SetTaskTemplate) {
      final comments =  (state as TaskLoaded).comments;
      final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
      final dir =  (state as TaskLoaded).appFilesDirectory;
      final isChanged=!(state as TaskLoaded).isChanged;
      final task = (state as TaskLoaded).task;
      task.template=event.template;
      if(event.template.propsList!=null){
        List<TasksFieldsModel> propsList=[];
        event.template.propsList?.forEach((element) {
          print("element.tabServerId ${element.tab} ${element.tabServerId} ${element.taskField?.name}");
          TasksFieldsModel tfm = TasksFieldsModel(
              id: element.id,
              usn: 0,
              serverId: 0,
              valueRequired: false,
              tab: element.tab,
              parentLocalId:0,
              taskField: element.taskField,
              tabServerId: element.tabServerId,
              fileValueList: <FileModel>[],
          );
          propsList.add(
              tfm
          );

        });
        task.propsList=propsList;
      }
      else
        task.propsList=null;
      //yield StartLoadingTaskPage();
      print("TaskLoaded");

      yield TaskLoaded(isChanged: isChanged,
          needToUpdateTaskList: false,
          task: task,
          nextTaskStatuses: nextTaskStatuses,
          appFilesDirectory: dir,
          comments:comments,
        showCommentTab:false,
        );

    }
    if (event is SetTaskEquipment) {
      final comments =  (state as TaskLoaded).comments;
      final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
      final dir =  (state as TaskLoaded).appFilesDirectory;
      final isChanged=!(state as TaskLoaded).isChanged;
      final task = (state as TaskLoaded).task;
      task.equipment=event.equipment;
      if(event.equipment.contractor!=null) {
        task.contractor = event.equipment.contractor;

        task.address = event.equipment.contractor?.address;
        task.addressFloor = event.equipment.contractor?.addressFloor;
        task.addressRoom = event.equipment.contractor?.addressRoom;
        task.addressInfo = event.equipment.contractor?.addressInfo;
        task.addressPorch = event.equipment.contractor?.addressPorch;
        task.lat = null;
        task.lon = null;
       /* if(event.equipment.contractor?.phones != null) {
          task.phones=[];
          event.equipment.contractor?.phones!.forEach((element) {
            PhoneModel p =
            PhoneModel(id: element.id, usn: 0, serverId: 0, name: element.name);
            task.phones!.add(p);
          });
        }
        else
          task.phones=null;
*/

        /*if(event.equipment.contractor?.persons != null) {
          task.persons=[];
          event.equipment.contractor?.persons!.forEach((element) {
            PersonModel p = PersonModel(id: element.id,
                usn: 0,
                serverId: 0,
                name: element.name,
                phones: null);

            if(element.phones != null) {
              p.phones=[];
              element.phones!.forEach((element_tel) {
                PhoneModel ph =
                PhoneModel(id: element_tel.id, usn: 0, serverId: 0, name: element_tel.name);
                p.phones!.add(ph);
              });
            }
            task.persons!.add(p);
          });
        }
        else
          task.persons=null;

         */

      }
      print("TaskLoaded ${event.equipment.contractor?.toJson()}");

      yield TaskLoaded(isChanged: isChanged,
          needToUpdateTaskList: false,
          task: task,
          nextTaskStatuses: nextTaskStatuses,
          appFilesDirectory: dir,
          comments:comments,
          showCommentTab:false,
        );

    }
    if (event is SetTaskAddress) {
      final comments =  (state as TaskLoaded).comments;
      final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
      final dir =  (state as TaskLoaded).appFilesDirectory;
      final isChanged=!(state as TaskLoaded).isChanged;
      final task = (state as TaskLoaded).task;

      task.address=event.address;
      task.addressFloor=event.addressFloor;
      task.addressRoom=event.addressRoom;
      task.addressInfo=event.addressInfo;
      task.addressPorch=event.addressPorch;
      task.lat=null;
      task.lon=null;
      print("TaskLoaded");

      yield TaskLoaded(isChanged: isChanged,
        needToUpdateTaskList: false,
        task: task,
        nextTaskStatuses: nextTaskStatuses,
        appFilesDirectory: dir,
        comments:comments,

        showCommentTab:false,
      );

    }
    if (event is DeletePhone) {
      final comments =  (state as TaskLoaded).comments;
      final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
      final dir =  (state as TaskLoaded).appFilesDirectory;
      final isChanged=!(state as TaskLoaded).isChanged;
      final task = (state as TaskLoaded).task;
      if(task.phones!=null) {
        PhoneModel? p = task.phones?.firstWhere((element) => element.id==event.id);
        if(p != null)
          task.phones?.remove(p);
      }
      TaskLoaded(isChanged: isChanged,
        needToUpdateTaskList: false,
        task: task,
        nextTaskStatuses: nextTaskStatuses,
        appFilesDirectory: dir,
        comments:comments,
        showCommentTab:false,
      );
    }
    if (event is AddPhone) {
      final comments =  (state as TaskLoaded).comments;
      final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
      final dir =  (state as TaskLoaded).appFilesDirectory;
      final isChanged=!(state as TaskLoaded).isChanged;
      final task = (state as TaskLoaded).task;


      final FoL = await addNewPhone(
          AddNewPhoneParams(name:event.value));
      yield FoL.fold((l) => TaskError(message:"bad"), (PhoneEntity phone)  {
        if(task.phones==null)
          task.phones=[];
        task.phones?.add(phone as PhoneModel);
        return TaskLoaded(isChanged: isChanged,
        needToUpdateTaskList: false,
        task: task,
            nextTaskStatuses: nextTaskStatuses,
            appFilesDirectory: dir,
            comments:comments,

          showCommentTab:false,
        );

      });
    }
    if (event is NewPlannedVisitTimeTaskEvent) {
      final comments =  (state as TaskLoaded).comments;
      final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
      final dir =  (state as TaskLoaded).appFilesDirectory;
      final isChanged=!(state as TaskLoaded).isChanged;
      final task = (state as TaskLoaded).task;
      print("wwwww ${(event.time!=null?event.time!.millisecondsSinceEpoch~/1000:null)}");
      task.plannedVisitTime=(event.time!=null?event.time!.millisecondsSinceEpoch~/1000:null);
      print("TaskLoaded");

      yield TaskLoaded(isChanged: isChanged,
        needToUpdateTaskList: false,
        task: task,
        nextTaskStatuses: nextTaskStatuses,
        appFilesDirectory: dir,
        comments:comments,
        showCommentTab:false,
      );

    }
    if (event is SetTaskContractor) {
      final comments =  (state as TaskLoaded).comments;
      final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
      final dir =  (state as TaskLoaded).appFilesDirectory;
      final isChanged=!(state as TaskLoaded).isChanged;
      final task = (state as TaskLoaded).task;
      task.contractor=event.contractor;
      if(event.contractor.address != null)
        task.address=event.contractor.address;
      if(event.contractor.addressFloor != null)
        task.addressFloor=event.contractor.addressFloor;
      if(event.contractor.addressRoom != null)
        task.addressRoom=event.contractor.addressRoom;
      if(event.contractor.addressInfo != null)
        task.addressInfo=event.contractor.addressInfo;
      if(event.contractor.addressPorch != null)
        task.addressPorch=event.contractor.addressPorch;
      if(event.contractor.lat != null)
        task.lat=event.contractor.lat;
      if(event.contractor.lon != null)
        task.lon=event.contractor.lon;
      //task.ph

/*      if(event.contractor.phones != null) {
        task.phones=[];
        event.contractor.phones!.forEach((element) {
          PhoneModel p =
              PhoneModel(id: element.id, usn: 0, serverId: 0, name: element.name);
          task.phones!.add(p);
        });
      }
      else
        task.phones=null;
*/
/*
      if(event.contractor.persons != null) {
        task.persons=[];
        event.contractor.persons!.forEach((element) {
          PersonModel p = PersonModel(id: element.id,
              usn: 0,
              serverId: 0,
              name: element.name,
              phones: null);

          if(element.phones != null) {
            p.phones=[];
            element.phones!.forEach((element_tel) {
              PhoneModel ph =
              PhoneModel(id: element_tel.id, usn: 0, serverId: 0, name: element_tel.name);
              p.phones!.add(ph);
            });
          }
          task.persons!.add(p);
        });
      }
      else
        task.persons=null;

 */
      print("TaskLoaded");

      //yield StartLoadingTaskPage();
      yield TaskLoaded(isChanged: isChanged,
          needToUpdateTaskList: false,
          task: task,
          nextTaskStatuses: nextTaskStatuses,
          appFilesDirectory: dir,
          comments:comments,
          showCommentTab:false,
        );

    }
    if (event is SetTaskPerson) {
      final comments =  (state as TaskLoaded).comments;
      final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
      final dir =  (state as TaskLoaded).appFilesDirectory;
      final isChanged=!(state as TaskLoaded).isChanged;
      final task = (state as TaskLoaded).task;
      print("event.person ${event.person.serverId} ${event.person.contractorPersonServerId}");
      task.persons=[event.person];
      yield TaskLoaded(isChanged: isChanged,
        needToUpdateTaskList: false,
        task: task,
        nextTaskStatuses: nextTaskStatuses,
        appFilesDirectory: dir,
        comments:comments,
        showCommentTab:false,
      );

      //getTask.
    }
    if (event is ChangeSelectionFieldValue) {
      //getTask.
      final task = (state as TaskLoaded).task;
      final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
      final isChanged = !(state as TaskLoaded).isChanged;
      //yield TaskSaved(task: task, nextTaskStatuses:nextTaskStatuses);
      print("element.id: ${task.id}");
      print("fieldId: ${event.fieldId}, ${task.toString()}");
      TasksFieldsModel? fieldElement=null;
      dynamic val=null;

      task.propsList?.forEach((element) {
        print("element.id: ${element.id}");
        if(element.id==event.fieldId) {
          fieldElement=element;
          print("${element.selectionValue?.name} ${event.value.toString()}");
          if(event.value!=null)
            element.taskField?.selectionValues?.forEach(
                    (sv) {
                      print("sv.id==event.value ${sv.id}==${event.value}");
                      if(sv.id==event.value)
                        val = sv;
                    });
          print("${element.taskField?.name}");
        }
      });
      print("val1 ${val?.name}");
      fieldElement?.selectionValue = val;
      if(fieldElement!=null) {
        final FoL = await setTaskFieldSelectionValue(
            SetTaskFieldSelectionValueParams(taskField: fieldElement!));
        FoL.fold((failure) {print("error");}, (
            nextTaskStatuses_readed) {

          syncToServer(ListSyncToServerParams());
          print("val ${val?.name}");

        });
      }



    task.checkList?.forEach((element) {
        print("element.id: ${element.id}");
        if(element.id==event.fieldId) {
          element.selectionValue = event.value;
          print("${element.taskField?.name}");
        }
      });
      //task.isChanged=!task.isChanged;

      print("task.isChanged ${task.isChanged}");
      //yield TaskLoaded(isChanged:isChanged, task: task, nextTaskStatuses:nextTaskStatuses);
    }
    if (event is AddPhotoToField) {
      final task = (state as TaskLoaded).task;
      final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
      final dir = (state as TaskLoaded).appFilesDirectory;
      final comments=(state as TaskLoaded).comments;
      bool isChanged = !(state as TaskLoaded).isChanged;
      task.propsList?.forEach((element) {
        if(event.fieldId==element.id){
          final FileModel picture = FileModel(id: 0, usn: 0, downloaded: false, size: 0, deleted: false);
          picture.waiting=true;
          if(element.fileValueList!=null)
            element.fileValueList?.add(picture);
          else
            element.fileValueList=[picture];

        }
        //element.waitingCount=0;

        print("picture + ${event.fieldId} ${element.id}");
      });
      yield TaskLoaded(isChanged: isChanged,
        needToUpdateTaskList: false,
        task: task,
        nextTaskStatuses: nextTaskStatuses,
        appFilesDirectory: dir,
        comments: comments,
        showCommentTab:false,
      );

      final ImagePicker _picker = ImagePicker();
      final pickedFile = await _picker.pickImage(
        source: event.src == PictureSourceEnum.camera?ImageSource.camera:ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 80,
      );
      if(pickedFile!=null) {
        print("pickedFile ${pickedFile.toString()}");
        print("TaskLoaded");


        Uint8List? data=await pickedFile.readAsBytes();
        final FoL = await getPictureFromCamera(
            GetPictureFromCameraParams(src: PictureSourceEnum.bytes,
                data: data));


        //Directory dir =  await getApplicationDocumentsDirectory();
        //yield StartLoadingTaskPage();
        yield await FoL.fold((failure) => TaskError(message: "bad"), (
            picture) async {
          final FoL = await addPictureToTaskField(
              AddPictureToTaskFieldParams(
                  taskFieldId: event.fieldId, pictureId: picture.id));
          return FoL.fold((l) => TaskError(message: "bad"), (
              FileModel picture) {
            task.propsList?.forEach((element) {
              if (event.fieldId == element.id) {
                //bool isAdd=false;
                /*if(element.fileValueList!=null){
                element.fileValueList?.forEach((pict) {
                  if(pict.waiting==true) {
                    pict = picture;
                    isAdd=true;
                  }
                });
              }*/
                for (var elem in element.fileValueList!) {
                  if (elem.waiting == true) {
                    element.fileValueList!.remove(elem);
                    break;
                  }
                }
                if (element.fileValueList != null)
                  element.fileValueList?.add(picture);
                else
                  element.fileValueList = [picture];
              }

              print("picture + ${event.fieldId} ${element.id}");
            });
            syncToServer(ListSyncToServerParams());
            isChanged = !(state as TaskLoaded).isChanged;
            print("TaskLoaded");

            return TaskLoaded(isChanged: isChanged,
                task: task,
                needToUpdateTaskList: false,
                nextTaskStatuses: nextTaskStatuses,
                appFilesDirectory: dir,
                comments: comments,
                showCommentTab:false,
            );
          });
          //syncToServer(ListSyncToServerParams());
        });
      }
      else{
        task.propsList?.forEach((element) {
          if(event.fieldId==element.id){
            final FileModel picture = FileModel(id: 0, usn: 0, downloaded: false, size: 0, deleted: false);
            element.fileValueList?.removeWhere((pElement) => pElement.id==0);
          }
          //element.waitingCount=0;

          print("picture + ${event.fieldId} ${element.id}");
        });

      }
      print("picture OK! 2!");
    }
    if (event is RemovePhotoFromField) {
      final task = (state as TaskLoaded).task;
      final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
      final dir =  (state as TaskLoaded).appFilesDirectory;
      final isChanged=!(state as TaskLoaded).isChanged;
      final comments=(state as TaskLoaded).comments;

        final FoL = await deletePictureToTaskField(
            DeletePictureToTaskFieldParams(taskFieldId: event.fieldId, pictureId: event.fileId));
        yield FoL.fold((l) => TaskError(message:"bad"), (FileModel picture)  {

          task.propsList?.forEach((element) {
            if(event.fieldId==element.id){
              //if(element.fileValueList!=null)
              //  element.fileValueList?.add(picture);
              //else
              //element.fileValueList=[];
              element.fileValueList?.removeWhere((pictureElement) => pictureElement.id == picture.id);

            }

            print("picture + ${event.fieldId} ${element.id}");
          });
          syncToServer(ListSyncToServerParams());
          print("TaskLoaded");

          return TaskLoaded(isChanged:isChanged,
              needToUpdateTaskList: false,
              task: task, nextTaskStatuses:nextTaskStatuses, appFilesDirectory: dir, comments: comments,showCommentTab:false,);
        });
        //syncToServer(ListSyncToServerParams());
    }
    if (event is AddSignatureToField) {
      final task = (state as TaskLoaded).task;
      final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
      final comments=(state as TaskLoaded).comments;

      final FoL = await getPictureFromCamera(
          GetPictureFromCameraParams(data:event.data, src: PictureSourceEnum.bytes));
      final isChanged = !(state as TaskLoaded).isChanged;

      Directory dir =  await getApplicationDocumentsDirectory();
      //yield StartLoadingTaskPage();
      yield await FoL.fold((failure) => TaskError(message:"bad"), (
          picture) async {

        final FoL = await addPictureToTaskField(
            AddPictureToTaskFieldParams(taskFieldId: event.fieldId, pictureId: picture.id));
        return FoL.fold((l) => TaskError(message:"bad"), (FileModel picture)  {

          task.propsList?.forEach((element) {
            if(event.fieldId==element.id){
              //if(element.fileValueList!=null)
              //  element.fileValueList?.add(picture);
              //else
                element.fileValueList=[picture];
            }

            print("picture + ${event.fieldId} ${element.id}");
          });
          syncToServer(ListSyncToServerParams());
          print("TaskLoaded");

          return TaskLoaded(isChanged:isChanged,
              needToUpdateTaskList: false,
              task: task, nextTaskStatuses:nextTaskStatuses, appFilesDirectory: dir.path, comments: comments, showCommentTab:false,);
        });
        //syncToServer(ListSyncToServerParams());
      });
      print("picture OK! 2!");
    }
    if (event is ChangeTextFieldValue) {
      //getTask.
      final task = (state as TaskLoaded).task;
      final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
      final isChanged = !(state as TaskLoaded).isChanged;
      //yield TaskSaved(task: task, nextTaskStatuses:nextTaskStatuses);
      print("element.id: ${task.id}");
      print("fieldId: ${event.fieldId}, ${task.toString()}");
      TasksFieldsModel? fieldElement=null;
      //dynamic val=event.value;

      task.propsList?.forEach((element) {
        print("element.id: ${element.id}");
        if(element.id==event.fieldId) {
          fieldElement=element;
        }
      });
      print("val1 ${event.value}");
      dynamic v=null;
      if(fieldElement?.taskField?.type.value==TaskFieldTypeEnum.text)
        fieldElement?.stringValue=event.value;
      else if(fieldElement?.taskField?.type.value==TaskFieldTypeEnum.number)
        fieldElement?.doubleValue =double.tryParse(event.value);
      //else if(fieldElement?.taskField?.type.value==TaskFieldTypeEnum.checkbox)
      //  return await db.updateTaskFieldValue(taskFieldId:taskField.id,taskFieldValue:taskField.boolValue==true?"1":"0");

      if(fieldElement!=null) {
        final FoL = await setTaskFieldSelectionValue(
            SetTaskFieldSelectionValueParams(taskField: fieldElement!));
        FoL.fold((failure) {print("error");}, (
            nextTaskStatuses_readed) {
          //syncToServer(ListSyncToServerParams());
          print("val ${event.value}");
          //fieldElement?.stringValue = event.value;
        });
      }



    task.checkList?.forEach((element) {
        print("element.id: ${element.id}");
        if(element.id==event.fieldId) {
          element.stringValue = event.value;
          print("${element.taskField?.name}");
        }
      });
      //task.isChanged=!task.isChanged;

      print("task.isChanged ${task.isChanged}");
      //yield TaskLoaded(isChanged:isChanged, task: task, nextTaskStatuses:nextTaskStatuses);
    }
    if (event is ChangeBoolFieldValue) {
      //getTask.
      final task = (state as TaskLoaded).task;
      final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
      final isChanged = !(state as TaskLoaded).isChanged;
      //yield TaskSaved(task: task, nextTaskStatuses:nextTaskStatuses);
      print("element.id: ${task.id}");
      print("fieldId: ${event.fieldId}, ${task.toString()}");
      TasksFieldsModel? fieldElement=null;
      //dynamic val=event.value;

      task.propsList?.forEach((element) {
        print("element.id: ${element.id}");
        if(element.id==event.fieldId) {
          fieldElement=element;
        }
      });
      print("val1 ${event.value}");
      dynamic v=null;
      fieldElement?.boolValue=event.value;
      //else if(fieldElement?.taskField?.type.value==TaskFieldTypeEnum.checkbox)
      //  return await db.updateTaskFieldValue(taskFieldId:taskField.id,taskFieldValue:taskField.boolValue==true?"1":"0");

      if(fieldElement!=null&&task.id!=0) {
        final FoL = await setTaskFieldSelectionValue(
            SetTaskFieldSelectionValueParams(taskField: fieldElement!));
        FoL.fold((failure) {print("error");}, (
            nextTaskStatuses_readed) {
          //syncToServer(ListSyncToServerParams());
          print("val ${event.value}");
          //fieldElement?.stringValue = event.value;
        });
      }



    task.checkList?.forEach((element) {
        print("element.id: ${element.id}");
        if(element.id==event.fieldId) {
          element.boolValue = event.value;
          print("${element.taskField?.name}");
        }
      });
      //task.isChanged=!task.isChanged;

      print("task.isChanged ${task.isChanged}");
      print("TaskLoaded");

      //yield TaskLoaded(isChanged:isChanged, task: task, nextTaskStatuses:nextTaskStatuses);
    }
    if (event is AddComment) {

      final task = (state as TaskLoaded).task;
      var date = new DateTime.now();
      int d = (date.toUtc().millisecondsSinceEpoch/1000).toInt();

      TaskCommentModel comment = TaskCommentModel(id: 0, mobile:true, localUsn: 0, usn: 0, message:event.value, task: TaskModel(id: task.id, serverId: task.serverId, unreadedCommentCount: 0), createdTime: d, dirty: true);
      final faiureOrLoading = await addTaskComment(AddTaskCommentParams(comment));

      final comments =  (state as TaskLoaded).comments;
      final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
      final dir =  (state as TaskLoaded).appFilesDirectory;
      final isChanged=!(state as TaskLoaded).isChanged;
      //yield StartLoadingTaskPage();
      yield faiureOrLoading.fold((failure) =>TaskError(message:"bad"), (comment) {
        syncToServer(ListSyncToServerParams());
        comments.insert(0,comment);
        print("TaskLoaded");

        return TaskLoaded(isChanged: isChanged,
          needToUpdateTaskList: false,
          task: task,
          nextTaskStatuses: nextTaskStatuses,
          appFilesDirectory: dir,
          comments:comments,
          showCommentTab:false,
        );
      });
    }
    if (event is CommentFileDownload) {
      final task = (state as TaskLoaded).task;
      final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
      final comments =  (state as TaskLoaded).comments;
      final dir =  (state as TaskLoaded).appFilesDirectory;
      final isChanged=!(state as TaskLoaded).isChanged;
      final int id=event.file!;
      print("readFile ${id}");

      comments.forEach((element) {
        print("element.file?.downloaded ${element.file?.downloaded}");
        if(element.file?.id==id){
          element.file?.downloading=true;
          print("element.file?.downloading ${element.file?.downloading}");
        }
      });
      //final faiureOrLoading = await loadFile(LoadFileParams(event.file!));
      print("TaskLoaded");

      yield TaskLoaded(isChanged: isChanged,
        needToUpdateTaskList: false,
        task: task,
        nextTaskStatuses: nextTaskStatuses,
        appFilesDirectory: dir,
        comments:comments,
        showCommentTab:false,
      );
      print("readFile ${id}");
      final faiureOrLoading = await loadFile(LoadFileParams(id));
      //!!await Future.delayed(Duration(seconds: 3));
      yield faiureOrLoading.fold((failure) =>TaskError(message:"bad"), (comment) {

        final task = (state as TaskLoaded).task;
        final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
        final comments =  (state as TaskLoaded).comments;
        final dir =  (state as TaskLoaded).appFilesDirectory;
        final isChanged=!(state as TaskLoaded).isChanged;
        final int id=event.file!;

        comments.forEach((element) {
          print("element.file?.downloaded ${element.file?.downloaded}");
          if(element.file?.id==id){
            element.file?.downloading=false;
            element.file?.downloaded=true;
            print("element.file?.downloading ${element.file?.downloading}");
          }
        });
        print("TaskLoaded");

        return TaskLoaded(isChanged: isChanged,
          needToUpdateTaskList: false,
          task: task,
          nextTaskStatuses: nextTaskStatuses,
          appFilesDirectory: dir,
          comments:comments,
          showCommentTab:false,
        );
      });
    }
    if (event is FieldFileUpdateDescription) {
      final task = (state as TaskLoaded).task;
      final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
      final comments = (state as TaskLoaded).comments;
      final dir = (state as TaskLoaded).appFilesDirectory;
      final isChanged = !(state as TaskLoaded).isChanged;
      //final int id = event.file;
      print("update file ${event.file.description}");
      final faiureOrLoading = await fileDescriptionSaver(
          SaveFileDescriptionParams(event.file));
      //print("readFile+ ${id}");
      //!!await Future.delayed(Duration(seconds: 3));
      yield faiureOrLoading.fold((failure) => TaskError(message: "bad"), (
          comment) {
        syncToServer(ListSyncToServerParams());
        return TaskLoaded(isChanged: isChanged,
          needToUpdateTaskList: false,
          task: task,
          nextTaskStatuses: nextTaskStatuses,
          appFilesDirectory: dir,
          comments:comments,
          showCommentTab:false,
        );
      });
    }
    if (event is GetTaskFromServer) {
      event.task.loading = true;
      //event.callback(event.task);
      final faiureOrLoading = await loadTask(LoadTaskParams(event.task.id,event.task.serverId));
      faiureOrLoading.fold((failure) =>TaskError(message:"bad"), (task) {
        print("${task.id}");
        event.callback1(task);
      });
    }
    if (event is FieldFileDownload) {
      final task = (state as TaskLoaded).task;
      final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
      final comments =  (state as TaskLoaded).comments;
      final dir =  (state as TaskLoaded).appFilesDirectory;
      final isChanged=!(state as TaskLoaded).isChanged;
      final int id=event.file!;
      print("readFile ${id}");

      task.propsList?.forEach((element) {
        print("element.file?.downloaded ${element.fileValueList}");
        element.fileValueList?.forEach((e) {
          if(e.id==id)
            e.downloading=true;
        });
      });
      //final faiureOrLoading = await loadFile(LoadFileParams(event.file!));
      print("TaskLoaded");

      yield TaskLoaded(isChanged: isChanged,
        needToUpdateTaskList: false,
        task: task,
        nextTaskStatuses: nextTaskStatuses,
        appFilesDirectory: dir,
        comments:comments,
        showCommentTab:false,
      );
      print("readFile ${id}");
      final faiureOrLoading = await loadFile(LoadFileParams(id));
      //print("readFile+ ${id}");
      //!!await Future.delayed(Duration(seconds: 3));
      yield faiureOrLoading.fold((failure) =>TaskError(message:"bad"), (comment) {

        final task = (state as TaskLoaded).task;
        final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
        final comments =  (state as TaskLoaded).comments;
        final dir =  (state as TaskLoaded).appFilesDirectory;
        final isChanged=!(state as TaskLoaded).isChanged;
        task.propsList?.forEach((element) {
          print("element.file?.downloaded ${element.fileValueList}");
          element.fileValueList?.forEach((e) {
            if(e.id==id) {
              e.downloading = false;
              e.downloaded = true;
            }
          });
        });
        print("TaskLoaded");

        return TaskLoaded(isChanged: isChanged,
          needToUpdateTaskList: false,
          task: task,
          nextTaskStatuses: nextTaskStatuses,
          appFilesDirectory: dir,
          comments:comments,
          showCommentTab:false,
        );
      });
    }
    if (event is AddPhotoToComment) {
      final task = (state as TaskLoaded).task;
      final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
      final comments =  (state as TaskLoaded).comments;
      final dir =  (state as TaskLoaded).appFilesDirectory;
      final isChanged=!(state as TaskLoaded).isChanged;

      final FoL = await getPictureFromCamera(
          GetPictureFromCameraParams(src: PictureSourceEnum.camera));
      //yield StartLoadingTaskPage();
      yield await FoL.fold((failure) => TaskError(message:"bad"), (
          picture) async {

        var date = new DateTime.now();
        int d = (date.toUtc().millisecondsSinceEpoch/1000).toInt();

        TaskCommentModel comment = TaskCommentModel(id: 0, mobile: true, localUsn: 0, usn: 0, message:"", file: picture, task: TaskModel(id: task.id, serverId: task.serverId, unreadedCommentCount: 0), createdTime: d, dirty: true);
        final faiureOrLoading = await addTaskComment(AddTaskCommentParams(comment));

        //yield StartLoadingTaskPage();
        return faiureOrLoading.fold((failure) =>TaskError(message:"bad"), (comment) {
          syncToServer(ListSyncToServerParams());
          comments.insert(0,comment);
          print("TaskLoaded");

          return TaskLoaded(isChanged: isChanged,
            needToUpdateTaskList: false,
            task: task,
            nextTaskStatuses: nextTaskStatuses,
            appFilesDirectory: dir,
            comments:comments,
            showCommentTab:false,
          );
        });

        /*TaskCommentModel comment = TaskCommentModel(id: 0, usn: 0, message:"", task: TaskModel(id: task.id, serverId: task.serverId), createdTime: d, dirty: true);
        final faiureOrLoading = await addTaskComment(AddTaskCommentParams(comment));

        final FoL = await addCommentWithPictureToTask(
            AddCommentWithPictureToTaskParams(taskId: task.id, pictureId: pictureId));
        return FoL.fold((l) => TaskError(message:"bad"), (TaskCommentModel comment)  {
*/
          /*task.propsList?.forEach((element) {
            if(event.fieldId==element.id){
              if(element.fileValueList!=null)
                element.fileValueList?.add(picture);
              else
                element.fileValueList=[picture];
            }

            print("picture + ${event.fieldId} ${element.id}");
          });
          syncToServer(ListSyncToServerParams());
          */

          //return TaskLoaded(isChanged:isChanged, task: task, nextTaskStatuses:nextTaskStatuses, appFilesDirectory: dir.path, comments: []);
       // });
        //syncToServer(ListSyncToServerParams());
      });
      print("picture OK! 2!");

     /* final task = (state as TaskLoaded).task;
      var date = new DateTime.now();
      int d = (date.toUtc().millisecondsSinceEpoch/1000).toInt();


      TaskCommentModel comment = TaskCommentModel(id: 0, usn: 0, message:"", task: TaskModel(id: task.id, serverId: task.serverId), createdTime: d, dirty: true);
      final faiureOrLoading = await addTaskComment(AddTaskCommentParams(comment));

      final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
      final dir =  (state as TaskLoaded).appFilesDirectory;
      final comments =  (state as TaskLoaded).comments;
      final isChanged=!(state as TaskLoaded).isChanged;
      //yield StartLoadingTaskPage();
      yield faiureOrLoading.fold((failure) =>TaskError(message:"bad"), (comment) {

        final FoL = await getPictureFromCamera(
            GetPictureFromCameraParams(parentId: comment.id, parent: PictureParentTypeEnum.taskComment));
*/
/*        final FoL = await getPictureFromCamera(
            GetPictureFromCameraParams(parentId: task.id, parent: PictureParentTypeEnum.taskComment));
        Directory dir =  await getApplicationDocumentsDirectory();
        yield StartLoadingTaskPage();
        yield FoL.fold((failure) => TaskError(message:"bad"), (
            picture) {
  */
   /*     comments.add(comment);
        syncToServer(ListSyncToServerParams());
        return TaskLoaded(isChanged: isChanged,
          task: task,
          nextTaskStatuses: nextTaskStatuses,
          appFilesDirectory: dir,
          comments:comments,
        );
      });*/
    }
    if (event is SaveNewTaskEvent) {
      final task = (state as TaskLoaded).task;
      Directory dir =  await getApplicationDocumentsDirectory();
      final isChanged=(state is TaskLoaded)?!(state as TaskLoaded).isChanged:true;
      //print("SetTaskStatus ${event.status} ${task.id} ${event.resolution} id:  ${event.id}");
      print("${(task as TaskModel).toMap()}");
      if(task.propsList!=null)
        task.propsList!.forEach((element) {
          print("propsList element ${element.taskField?.name} ${(element.boolValue==true?"true":"false")} ${(element.stringValue)} ");
        });
      //task.employees=[EmployeeModel(id: 0, usn: 0, serverId: 1, name: "name", webAuth: false, mobileAuth: true)];
      final fOl = await createTaskOnServer(CreateTaskOnServerParams(task:task));
      yield StartLoadingTaskPage();
      yield await fOl.fold(
              (l) => TaskError(message: "message"),
              (TaskEntity task_readed) async {
                print("task_readed ${(task_readed as TaskModel).toMap()}");
                event.callback();
                final FoL = await nextTaskStatusesReader(TaskStatusParams(id: task_readed.status?.id, lifecycle: task_readed.lifecycle?.id,));

                return FoL.fold((failure) =>TaskError(message:"bad"), (nextTaskStatuses_readed) async {
                  //final FoL = await nextTaskStatuses(TaskStatusParams(id: task.status?.id));
                  print("TaskLoaded");

                    return TaskLoaded(isChanged:isChanged,
                        needToUpdateTaskList: false,
                        task: task_readed, nextTaskStatuses:nextTaskStatuses_readed, appFilesDirectory: dir.path, comments:[], showCommentTab:false,);

                });

              }
      );

      final faiureOrLoading = await saveNewTask(SaveNewTaskParams(
        task: task,
      ));



      /*return await faiureOrLoading.fold((failure) async =>TaskError(message:"bad"), (task_readed) async {
        //this.task = task_readed;
        final FoL = await nextTaskStatusesReader(TaskStatusParams(id: task_readed.status?.id, lifecycle: task_readed.lifecycle?.id,));
        return FoL.fold((failure) =>TaskError(message:"bad"), (nextTaskStatuses_readed) {
          //this.nextTaskStatuses = nextTaskStatuses_readed;
          //final FoL = await nextTaskStatuses(TaskStatusParams(id: task.status?.id));
          print("nextTaskStatuses = ${nextTaskStatuses_readed.toString()} ${task_readed.toString()}");
          syncToServer(ListSyncToServerParams());
          return TaskLoaded(isChanged:true,
              needToUpdateTaskList: true,
              task: task_readed, nextTaskStatuses:nextTaskStatuses_readed, appFilesDirectory: dir.path, comments:[]);

        });*/
        //return TaskLoaded(task: task);
     // });

    }
    if (event is ChangeTaskStatus) {
      //await Future.delayed(Duration(seconds: 2));
      final task = (state as TaskLoaded).task;

      yield StartLoadingTaskPage();
      yield await _setNewTaskStatus(event, task);
    }
    if (event is NewTask) {
      Directory dir =  await getApplicationDocumentsDirectory();
      final isChanged=(state is TaskLoaded)?!(state as TaskLoaded).isChanged:true;
      var date = new DateTime.now();
      print("TaskLoaded");
      List<TasksFieldsModel>? propsList=null;

      if(event.template.propsList!=null){
        propsList=[];

        event.template.propsList?.forEach((element) {
          print("element.tabServerId ${element.tab} ${element.tabServerId} ${element.taskField?.name}");
          TasksFieldsModel tfm = TasksFieldsModel(
            id: element.id,
            usn: 0,
            serverId: 0,
            valueRequired: false,
            tab: element.tab,
            parentLocalId:0,
            taskField: element.taskField,
            tabServerId: element.tabServerId,
            fileValueList: <FileModel>[],
          );
          propsList!.add(
              tfm
          );

        });
      }

      yield TaskLoaded(isChanged:isChanged,
          needToUpdateTaskList: false,
          task:
            TaskModel(
                id: 0,
                serverId: 0,
                plannedVisitTime: date.millisecondsSinceEpoch~/1000,
                lat: null,
                lon: null,
                template:  event.template,
                propsList: propsList,
                unreadedCommentCount:0,


            ), nextTaskStatuses:[], appFilesDirectory: dir.path, comments:[],showCommentTab:false,);
      //navigatorKey.currentState?.pushNamed('TaskDetailPage');
      di.sl<NavigationService>().navigatorKey.currentState?.pushNamed('TaskDetailPage');
      print("start sync");
    }
    if (event is ReloadTask) {
      print("start sync");
      //TaskModel t=//task.taskRepository()
      yield StartLoadingTaskPage();
      Directory dir =  await getApplicationDocumentsDirectory();

      // await Future.delayed(Duration(seconds: 2));
      final faiureOrLoading = await taskReader(TaskParams(id: event.id));

      //print("start sync1");
      //yield TaskListEmpty();
      yield await faiureOrLoading.fold((failure) async =>TaskError(message:"bad"), (task_readed) async {
        final FoL = await nextTaskStatusesReader(TaskStatusParams(id: task_readed.status?.id, lifecycle: task_readed.lifecycle?.id,));
        return FoL.fold((failure) =>TaskError(message:"bad"), (List<TaskLifeCycleNodeEntity> nextTaskStatuses_readed) async {
          //final FoL = await nextTaskStatuses(TaskStatusParams(id: task.status?.id));
          print("nextTaskStatuses = ${nextTaskStatuses_readed.toString()}");
          TaskStatusModel? readedStatus = null;
          readedStatus = nextTaskStatuses_readed.firstWhereOrNull((element) => element.nextStatus.systemStatusId == 3)?.nextStatus;
          if(task_readed.status?.systemStatusId == 1 && readedStatus != null){
            var date = new DateTime.now();
            return await _setNewTaskStatus(ChangeTaskStatus(
              status: readedStatus.id,
              comment: "",
              createdTime: date,
              manualTime: date,
              timeChanging: false,
              dateChanging: false,
              commentChanging: false,
              commentRequired: false,
            ), task_readed);
          }
          else{
            print("TaskLoaded");

            return TaskLoaded(isChanged:true,
                needToUpdateTaskList: false,
                task: task_readed, nextTaskStatuses:nextTaskStatuses_readed, appFilesDirectory: dir.path, comments:[], showCommentTab:false,);
          }
        });
        //return TaskLoaded(task: task);
      });
    }
    if (event is ReloadTaskByExternalID) {
      print("start sync");
      //TaskModel t=//task.taskRepository()
      yield StartLoadingTaskPage();
      Directory dir =  await getApplicationDocumentsDirectory();

      // await Future.delayed(Duration(seconds: 2));
      print("event.externaId ${event.externaId}");
      final faiureOrLoading = await taskReader(TaskParams(id:0, externalId: event.externaId));

      //print("start sync1");
      //yield TaskListEmpty();
      yield await faiureOrLoading.fold((failure) async =>TaskError(message:"bad"), (task_readed) async {
        final FoL = await nextTaskStatusesReader(TaskStatusParams(id: task_readed.status?.id, lifecycle: task_readed.lifecycle?.id,));
        return FoL.fold((failure) =>TaskError(message:"bad"), (List<TaskLifeCycleNodeEntity> nextTaskStatuses_readed) async {
          //final FoL = await nextTaskStatuses(TaskStatusParams(id: task.status?.id));
          print("nextTaskStatuses = ${nextTaskStatuses_readed.toString()}");
          TaskStatusModel? readedStatus = null;
          readedStatus = nextTaskStatuses_readed.firstWhereOrNull((element) => element.nextStatus.systemStatusId == 3)?.nextStatus;
          if(task_readed.status?.systemStatusId == 1 && readedStatus != null){
            var date = new DateTime.now();
            return await _setNewTaskStatus(ChangeTaskStatus(
              status: readedStatus.id,
              comment: "",
              createdTime: date,
              manualTime: date,
              timeChanging: false,
              dateChanging: false,
              commentChanging: false,
              commentRequired: false,
            ), task_readed);
          }
          else{
            print("TaskLoaded");

            return TaskLoaded(isChanged:true,
                needToUpdateTaskList: false,
                task: task_readed,
                nextTaskStatuses:nextTaskStatuses_readed,
                appFilesDirectory: dir.path,
                comments:[],
                showCommentTab:event.showCommentTab,
            );
          }
        });
        //return TaskLoaded(task: task);
      });
    }

  }

  Stream<TaskState> _mapRefreshTaskToState() async* {
    final currentState = state;
    id = 0;
    var oldTasks = <TaskEntity>[];
    //m.incrementCounter();
    /*if(currentState is TaskListLoaded)
    {
      oldTasks = currentState.tasksList;
    }
*/

//    yield TaskListLoading(oldTasks,isFirstFetch: page==0);
    final faiureOrLoading = await taskReader(TaskParams(id: id));

/*    yield faiureOrLoading.fold((failure)=>TaskListError(message:_mapFailureToMessage(failure)), (task) {
      page++;
      //final tasks = (state as TaskListLoading).oldPersonList;
      //tasks.addAll(task);
      return TaskListLoaded(tasksList: task);
    });//TaskListLoaded(tasksList: task));
*/

  }
  Future<TaskState> _setNewTaskStatus(ChangeTaskStatus event, TaskEntity task) async{
    //final curretnState = state;
    Directory dir =  await getApplicationDocumentsDirectory();
    print("SetTaskStatus ${event.status} ${task.id} ${event.resolution} id:  ${event.id}");
    final faiureOrLoading = await setTaskStatus(SetTaskStatusParams(
      id: event.id,
      task: task.id,
      status: event.status,
      resolution: event.resolution,
      manualTime: event.manualTime,
      createdTime: event.createdTime,
      comment: event.comment,
      timeChanging:event.timeChanging,
      dateChanging:event.dateChanging,
      commentChanging:event.commentChanging,
      commentRequired:event.commentRequired,
    ));

    return await faiureOrLoading.fold((failure) async =>TaskError(message:"bad"), (task_readed) async {
      //this.task = task_readed;
      final FoL = await nextTaskStatusesReader(TaskStatusParams(id: task_readed.status?.id, lifecycle: task_readed.lifecycle?.id,));
      return FoL.fold((failure) =>TaskError(message:"bad"), (nextTaskStatuses_readed) {
        //this.nextTaskStatuses = nextTaskStatuses_readed;
        //final FoL = await nextTaskStatuses(TaskStatusParams(id: task.status?.id));
        print("nextTaskStatuses = ${nextTaskStatuses_readed.toString()} ${task_readed.toString()}");
        syncToServer(ListSyncToServerParams());
        print("TaskLoaded");

        return TaskLoaded(isChanged:true,
            needToUpdateTaskList: true,
            task: task_readed, nextTaskStatuses:nextTaskStatuses_readed, appFilesDirectory: dir.path, comments:[],
          showCommentTab:false,);

      });
      //return TaskLoaded(task: task);
    });

  }
}
/*
  Stream<TaskListState> _mapFetchTaskToState() async*{
    final currentState = state;
    //SyncReady();
    //yield Stream.fromFutures([wait10()]).listen(listener);
    var oldTasks = <TaskEntity>[];
    if(currentState is TaskListLoaded)
    {
      oldTasks = currentState.tasksList;
    }

    yield TaskListLoading(oldTasks,isFirstFetch: page==0);
    print("page: $page");
    final faiureOrLoading = await listTask(ListTaskParams(page: page));

    yield faiureOrLoading.fold(
            (failure) => TaskListError(message:_mapFailureToMessage(failure)),
            (task) {
              page++;
              final tasks = (state as TaskListLoading).oldPersonList;
              tasks.addAll(task);
              return TaskListLoaded(tasksList: tasks);
            });//TaskListLoaded(tasksList: task));


  }
  Stream<TaskListState> listener(event) async*{
    yield TaskListError(message:"eee");
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

}*/