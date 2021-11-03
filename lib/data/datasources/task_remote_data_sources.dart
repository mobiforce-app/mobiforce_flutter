import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/core/error/exception.dart';
import 'package:mobiforce_flutter/data/models/employee_model.dart';
import 'package:mobiforce_flutter/data/models/file_model.dart';
import 'package:mobiforce_flutter/data/models/task_comment_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:http/http.dart' as http;
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/data/models/tasksstatuses_model.dart';
import 'package:mobiforce_flutter/data/models/taskstatus_model.dart';
import 'package:mobiforce_flutter/domain/entity/taskfield_entity.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class TaskRemoteDataSources{
  Future<int> newTaskPicture();
  Future<List<TaskModel>>searchTask(String query);
  Future<List<TaskModel>>getAllTask(int page);
  Future<TaskModel>getTask(int id);
  Future<List<TaskStatusModel>>getTaskStatusGraph(int? id, int? lifecycle);
  Future<FileModel>loadFileFromWeb(int id);
  Future<List<TaskCommentModel>> getCommentList({required int task,required int page});
  Future<TaskModel> setTaskStatus({required int status,required int task, int? resolution});
  Future<bool> setTaskFieldSelectionValue({required TasksFieldsModel taskField});
  Future<FileModel> addPictureTaskField({required int taskFieldId,required int pictureId});
  Future<FileModel> deletePictureTaskField({required int taskFieldId,required int pictureId});
  //Future<FileModel> addPictureTaskComment({required int taskCommentId,required int pictureId});
  Future<TaskCommentModel> addTaskComment({required TaskCommentModel comment});
}

class TaskRemoteDataSourcesImpl implements TaskRemoteDataSources
{
  final http.Client client;
  final SharedPreferences sharedPreferences;
  final DBProvider db;
  TaskRemoteDataSourcesImpl({required this.client,required this.sharedPreferences, required this.db});


  @override
  Future<List<TaskModel>> searchTask(String query) => _getTaskFromUrl(url: "https://mobifors111.mobiforce.ru/api2.0/get-tasks.php", page:0);

  @override
  Future<List<TaskModel>> getAllTask(int page) => _getTaskFromUrl(url: "https://mobifors111.mobiforce.ru/api2.0/get-tasks.php", page:page);

  @override
  Future<List<TaskStatusModel>> getTaskStatusGraph(int ?id, int? lifecycle) async
  {
    return await db.getNextStatuses(id, lifecycle);
  }

  @override
  Future<FileModel>loadFileFromWeb(int id) async
  {
    String domain=sharedPreferences.getString("domain")??"";
    String accessToken=sharedPreferences.getString("access_token")??"";

    final f = await db.readFile(id);
    print("remote file: ${f.serverId}");
    print("domain=$domain, access_token=$accessToken");
    final response = await http.get(Uri.parse("https://$domain/api2.0/get-file.php?id=${f.serverId}"),headers:{
      HttpHeaders.authorizationHeader: "key=\"$accessToken\"",
    });
    print("readFile load ${response.bodyBytes.toString()}");
    final directory = await getApplicationDocumentsDirectory();
    //final path = await _localPath;
    print('${directory.path}/photo.jpg');
    final file = File('${directory.path}/photo_$id.jpg');
    //List<int> bytes = await picture.readAsBytes();
    if(response.bodyBytes!=null) {
      file.writeAsBytes(response.bodyBytes);
      f.downloaded=true;
      await db.updateFile(f);
    }
    return f;
  }

  @override
  Future<FileModel> addPictureTaskField({required int taskFieldId,required int pictureId}) async
  {
    int id = await db.addPictureToTaskField(taskFieldId:taskFieldId,pictureId:pictureId);
    return FileModel(id: id, usn:0,downloaded: true, size:0, deleted: false);
  }
  @override
  Future<FileModel> deletePictureTaskField({required int taskFieldId,required int pictureId}) async
  {
    int id = await db.deletePictureFromTaskField(taskFieldId:taskFieldId,pictureId:pictureId);
    return FileModel(id: id, usn:0,downloaded: true, size:0, deleted: false);
  }

  /*@override
  Future<FileModel> addPictureTaskComment({required int taskCommentId,required int pictureId}) async
  {
    int id = await db.addPictureToTaskComment(taskCommentId:taskCommentId,pictureId:pictureId);
    return FileModel(id: id, usn:0);
  }*/
  @override
  Future<List<TaskCommentModel>> getCommentList({required int task,required int page}) async
  {
    return await db.getCommentList(task:task,page:page);
    //return
      ;//FileModel(id: id, usn:0);
  }
  @override
  Future<TaskCommentModel> addTaskComment({required TaskCommentModel comment}) async
  {
    print("insert comment to base");
    //int usn = await db.getUSN();
    final int selfId = sharedPreferences.getInt("self_id")??0;
    print("self_id $selfId");
    if(selfId!=0){
      EmployeeModel? empl = await db.getEmployee(await db.getEmployeeIdByServerId(selfId));
      comment.author=empl;
    }
    comment.localUsn = await db.getUSN();
    comment = await db.insertTaskComment(comment);
    if(comment.file!=null)
    {
      await db.addPictureToTaskComment(taskCommentId:comment.id,pictureId:comment.file?.id);
      //return FileModel(id: id, usn:0);
    }

    return comment;
    //return
      ;//FileModel(id: id, usn:0);
  }
  @override
  Future<TaskModel> getTask(int id) async{
    return await db.getTask(id);
  }
  @override
  Future<int> newTaskPicture() async{
    return await db.newFileRecord();
  }
  @override
  Future<TaskModel> setTaskStatus({required int status,required int task, int? resolution}) async{

    var date = new DateTime.now();
    int d = (date.toUtc().millisecondsSinceEpoch/1000).toInt();
    TasksStatusesModel ts = TasksStatusesModel(id:0,usn:0,serverId: null, status:TaskStatusModel(serverId: 0,id:status, color:"", name:"", usn: 0),
        task:TaskModel(serverId:0,id:task),
        createdTime: d, manualTime: d, lat: 0.0, lon:0.0, dirty:true);
    print("resolution $resolution");
    await db.addStatusToTask(ts:ts,resolution: resolution,update_usn: true);
    return await db.getTask(task);
  }

  @override
  Future<bool> setTaskFieldSelectionValue({required TasksFieldsModel taskField}) async{
    print("taskField.taskField?.type.value = ${taskField.taskField?.type.value}, ${taskField.id} , ${taskField.selectionValue?.id}");
    if(taskField.taskField?.type.value==TaskFieldTypeEnum.optionlist)
      return await db.updateTaskFieldSelectionValue(taskFieldId:taskField.id,taskFieldSelectionValue:taskField.selectionValue?.id,update_usn: true);
    else if(taskField.taskField?.type.value==TaskFieldTypeEnum.text)
      return await db.updateTaskFieldValue(taskFieldId:taskField.id,taskFieldValue:taskField.stringValue,update_usn: true);
    else if(taskField.taskField?.type.value==TaskFieldTypeEnum.number)
      return await db.updateTaskFieldValue(taskFieldId:taskField.id,taskFieldValue:"${taskField.doubleValue}",update_usn: true);
    else if(taskField.taskField?.type.value==TaskFieldTypeEnum.checkbox)
      return await db.updateTaskFieldValue(taskFieldId:taskField.id,taskFieldValue:taskField.boolValue==true?"1":"0",update_usn: true);
    return false;
  }


  Future<List<TaskModel>> _getTaskFromUrl({required String url,required int page}) async{
    return await db.getTasks(page);
    /*final token=sharedPreferences.getString("access_token");
    print(token);
    try{
      Map data = {
        'filters': '{"groupOp":"AND","rules":[]}',
        'nd': 1629978655643,
        'page': page,
        'rows': 30,
        'sidx': 'ID',
        'sord': 'asc',
        'tableId': 'clients_grid',
        'updateCounter': 0,
        '_search': true
      };
      final response = await client.post(Uri.parse(url),headers:{'Content-Type':"application/json","AUTHORIZATION":"key=$token"},body: json.encode(data));
      if(response.statusCode == 200){
        final tasks = json.decode(response.body);
        return (tasks['results'] as List).map((task)=> TaskModel.fromJson(task)).toList();
      }
      else{
        print("My exception");
        throw ServerException();
      }
    }
    catch (error) {
      print("error!!! $error");
      throw ServerException();
    }*/
  }
  
}