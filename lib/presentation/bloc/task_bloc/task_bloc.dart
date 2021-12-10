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
import 'package:mobiforce_flutter/data/models/task_comment_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/data/models/taskstatus_model.dart';
import 'package:mobiforce_flutter/domain/entity/sync_status_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskfield_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';
import 'package:mobiforce_flutter/domain/usecases/add_picture_to_field.dart';
//import 'package:mobiforce_flutter/domain/usecases/add_picture_to_task_comment.dart';
import 'package:mobiforce_flutter/domain/usecases/add_task_comment.dart';
import 'package:mobiforce_flutter/domain/usecases/authorization_check.dart';
import 'package:mobiforce_flutter/domain/usecases/delete_picture_from_field.dart';
import 'package:mobiforce_flutter/domain/usecases/get_all_tasks.dart';
import 'package:mobiforce_flutter/domain/usecases/get_picture_from_camera.dart';
import 'package:mobiforce_flutter/domain/usecases/get_task_detailes.dart';
import 'package:mobiforce_flutter/domain/usecases/get_task_status_graph.dart';
import 'package:mobiforce_flutter/domain/usecases/get_tasks_comments.dart';
import 'package:mobiforce_flutter/domain/usecases/load_file.dart';
import 'package:mobiforce_flutter/domain/usecases/set_task_field_value.dart';
import 'package:mobiforce_flutter/domain/usecases/set_task_status.dart';
import 'package:mobiforce_flutter/domain/usecases/sync_to_server.dart';
import 'package:mobiforce_flutter/domain/usecases/wait.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/blockSteam.dart';
//import 'package:mobiforce_flutter/domain/usecases/search_task.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_state.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_state.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:dartz/dartz.dart';
// import 'equatabl'
//enum PictureSourceEnum {camera, gallery}

class TaskBloc extends Bloc<TaskEvent,TaskState> {
  final GetTask taskReader;

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
  //final ModelImpl m;
  //final WaitDealys10 wait10;

  //final _counterStreamController = StreamController<int>();
  //StreamSink<int> get counter_sink => _counterStreamController.sink;
// expose data from stream
//  Stream<int> get stream_counter => _counterStreamController.stream;

  int id = 0;

  TaskBloc({
    required this.taskReader,
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

   // required this.addCommentWithPictureToTask,
  }) : super(TaskEmpty()) {

  }

  //m.counterUpdates.listen((item) => print(item)); // использование лямбда-функции

  //StreamSubscription streamSubscription = MyApp.model.counterUpdates.listen((newVal) => setState(() {
  //_counter = newVal;
  //}));
  //

  @override
  Stream<TaskState> mapEventToState(TaskEvent event) async* {
    print("tasklist bloc map event " + event.toString());
    if (event is ShowTaskComment&&(state.runtimeType == TaskLoaded)){
      final task = (state as TaskLoaded).task;
      final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
      final dir =  (state as TaskLoaded).appFilesDirectory;
      final isChanged=!(state as TaskLoaded).isChanged;
      final comments=(state as TaskLoaded).comments;
      print("(state as TaskLoaded).comments ${(state as TaskLoaded).comments}");
      //yield StartLoadingTaskPage();
      if(comments.length==0) {
        final FoL = await getTaskComments(
            GetTaskCommentsParams
              (task: task.id, page: 0));
        //await await Future.delayed(Duration(seconds: 2));
        yield FoL.fold((failure) => TaskError(message: "bad"), (comments) {
          return TaskLoaded(isChanged: isChanged,
            task: task,
            nextTaskStatuses: nextTaskStatuses,
            appFilesDirectory: dir,
            comments: comments,
          );
        });
      }
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
      bool isChanged = !(state as TaskLoaded).isChanged;

      final ImagePicker _picker = ImagePicker();
      final pickedFile = await _picker.pickImage(
        source: event.src == PictureSourceEnum.camera?ImageSource.camera:ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 80,
      );
      if(pickedFile!=null) {
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
        print("pickedFile ${pickedFile.toString()}");
        yield TaskLoaded(isChanged: isChanged,
            task: task,
            nextTaskStatuses: nextTaskStatuses,
            appFilesDirectory: dir,
            comments: []);

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
            return TaskLoaded(isChanged: isChanged,
                task: task,
                nextTaskStatuses: nextTaskStatuses,
                appFilesDirectory: dir,
                comments: []);
          });
          //syncToServer(ListSyncToServerParams());
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
              element.fileValueList=[];
            }

            print("picture + ${event.fieldId} ${element.id}");
          });
          syncToServer(ListSyncToServerParams());
          return TaskLoaded(isChanged:isChanged, task: task, nextTaskStatuses:nextTaskStatuses, appFilesDirectory: dir, comments: []);
        });
        //syncToServer(ListSyncToServerParams());
    }
    if (event is AddSignatureToField) {
      final task = (state as TaskLoaded).task;
      final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
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
          return TaskLoaded(isChanged:isChanged, task: task, nextTaskStatuses:nextTaskStatuses, appFilesDirectory: dir.path, comments: []);
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
          element.boolValue = event.value;
          print("${element.taskField?.name}");
        }
      });
      //task.isChanged=!task.isChanged;

      print("task.isChanged ${task.isChanged}");
      //yield TaskLoaded(isChanged:isChanged, task: task, nextTaskStatuses:nextTaskStatuses);
    }
    if (event is AddComment) {

      final task = (state as TaskLoaded).task;
      var date = new DateTime.now();
      int d = (date.toUtc().millisecondsSinceEpoch/1000).toInt();

      TaskCommentModel comment = TaskCommentModel(id: 0, localUsn: 0, usn: 0, message:event.value, task: TaskModel(id: task.id, serverId: task.serverId), createdTime: d, dirty: true);
      final faiureOrLoading = await addTaskComment(AddTaskCommentParams(comment));

      final comments =  (state as TaskLoaded).comments;
      final nextTaskStatuses = (state as TaskLoaded).nextTaskStatuses;
      final dir =  (state as TaskLoaded).appFilesDirectory;
      final isChanged=!(state as TaskLoaded).isChanged;
      //yield StartLoadingTaskPage();
      yield faiureOrLoading.fold((failure) =>TaskError(message:"bad"), (comment) {
        syncToServer(ListSyncToServerParams());
        comments.insert(0,comment);
        return TaskLoaded(isChanged: isChanged,
          task: task,
          nextTaskStatuses: nextTaskStatuses,
          appFilesDirectory: dir,
          comments:comments,
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

      yield TaskLoaded(isChanged: isChanged,
        task: task,
        nextTaskStatuses: nextTaskStatuses,
        appFilesDirectory: dir,
        comments:comments,
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

        return TaskLoaded(isChanged: isChanged,
          task: task,
          nextTaskStatuses: nextTaskStatuses,
          appFilesDirectory: dir,
          comments:comments,
        );
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

      yield TaskLoaded(isChanged: isChanged,
        task: task,
        nextTaskStatuses: nextTaskStatuses,
        appFilesDirectory: dir,
        comments:comments,
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

        return TaskLoaded(isChanged: isChanged,
          task: task,
          nextTaskStatuses: nextTaskStatuses,
          appFilesDirectory: dir,
          comments:comments,
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

        TaskCommentModel comment = TaskCommentModel(id: 0, localUsn: 0, usn: 0, message:"", file: picture, task: TaskModel(id: task.id, serverId: task.serverId), createdTime: d, dirty: true);
        final faiureOrLoading = await addTaskComment(AddTaskCommentParams(comment));

        //yield StartLoadingTaskPage();
        return faiureOrLoading.fold((failure) =>TaskError(message:"bad"), (comment) {
          syncToServer(ListSyncToServerParams());
          comments.insert(0,comment);
          return TaskLoaded(isChanged: isChanged,
            task: task,
            nextTaskStatuses: nextTaskStatuses,
            appFilesDirectory: dir,
            comments:comments,
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
    if (event is ChangeTaskStatus) {
      //await Future.delayed(Duration(seconds: 2));
      final task = (state as TaskLoaded).task;

      yield StartLoadingTaskPage();

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
      yield await faiureOrLoading.fold((failure) async =>TaskError(message:"bad"), (task_readed) async {
        //this.task = task_readed;
        final FoL = await nextTaskStatusesReader(TaskStatusParams(id: task_readed.status?.id, lifecycle: task_readed.lifecycle?.id,));
        return FoL.fold((failure) =>TaskError(message:"bad"), (nextTaskStatuses_readed) {
          //this.nextTaskStatuses = nextTaskStatuses_readed;
          //final FoL = await nextTaskStatuses(TaskStatusParams(id: task.status?.id));
          print("nextTaskStatuses = ${nextTaskStatuses_readed.toString()} ${task_readed.toString()}");
          syncToServer(ListSyncToServerParams());
          return TaskLoaded(isChanged:true, task: task_readed, nextTaskStatuses:nextTaskStatuses_readed, appFilesDirectory: dir.path, comments:[]);

        });
        //return TaskLoaded(task: task);
      });
    }
    /*if (event is SetTaskReaded) {
      //await Future.delayed(Duration(seconds: 2));
      final task = (state as TaskLoaded).task;

      yield StartLoadingTaskPage();

      print("SetTaskReaded");
      //int readedStatusId=await setTaskStatus(SetTaskStatusParams(task: task.id,status: event.status));
      final faiureOrLoading = await setTaskStatus(SetTaskStatusParams(task: task.id,status: event.status));
      yield await faiureOrLoading.fold((failure) async =>TaskError(message:"bad"), (task_readed) async {
        //this.task = task_readed;
        final FoL = await nextTaskStatusesReader(TaskStatusParams(id: task_readed.status?.id));
        return FoL.fold((failure) =>TaskError(message:"bad"), (nextTaskStatuses_readed) {
          //this.nextTaskStatuses = nextTaskStatuses_readed;
          //final FoL = await nextTaskStatuses(TaskStatusParams(id: task.status?.id));
          print("nextTaskStatuses = ${nextTaskStatuses_readed.toString()} ${task_readed.toString()}");
          return TaskLoaded(isChanged:true, task: task_readed, nextTaskStatuses:nextTaskStatuses_readed);
        });
        //return TaskLoaded(task: task);
      });
    }*/
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
        return FoL.fold((failure) =>TaskError(message:"bad"), (nextTaskStatuses_readed) {
          //final FoL = await nextTaskStatuses(TaskStatusParams(id: task.status?.id));
          print("nextTaskStatuses = ${nextTaskStatuses_readed.toString()}");
          return TaskLoaded(isChanged:true, task: task_readed, nextTaskStatuses:nextTaskStatuses_readed, appFilesDirectory: dir.path, comments:[]);
        });
        //return TaskLoaded(task: task);
      });
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