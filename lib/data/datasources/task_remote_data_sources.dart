import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/core/error/exception.dart';
import 'package:mobiforce_flutter/data/models/employee_model.dart';
import 'package:mobiforce_flutter/data/models/file_model.dart';
import 'package:mobiforce_flutter/data/models/phone_model.dart';
import 'package:mobiforce_flutter/data/models/resolution_group_model.dart';
import 'package:mobiforce_flutter/data/models/resolution_model.dart';
import 'package:mobiforce_flutter/data/models/task_comment_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:http/http.dart' as http;
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/data/models/tasksstatuses_model.dart';
import 'package:mobiforce_flutter/data/models/taskstatus_model.dart';
import 'package:mobiforce_flutter/domain/entity/phone_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_life_cycle_node_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskfield_entity.dart';
import 'package:mobiforce_flutter/domain/entity/tasksstatuses_entity.dart';
import 'package:mobiforce_flutter/domain/entity/user_setting_entity.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entity/task_comment_entity.dart';
import '../models/template_model.dart';

abstract class TaskRemoteDataSources{
  Future<int> newTaskPicture();
  Future<List<TaskModel>>searchTask(String query);
  Future<List<TaskModel>>getAllTask(int page);
  Future<List<TemplateModel>>getAllTemplates(int page);
  Future<TaskModel>getTask(int id);
  Future<TaskModel>getTaskByExternalId(int eternalId);
  Future<List<TaskLifeCycleNodeEntity>>getTaskStatusGraph(int? id, int? lifecycle);
  Future<UserSettingEntity>getUserSetting();
  void setFilter({DateTime? dateFrom, DateTime? dateTill});

  Future<FileModel>loadFileFromWeb(int id);
  Future<List<int>> getTasksMounthCounter(DateTime from, DateTime till);
  Future<bool>saveFileDescription(FileModel file);
  Future<List<TaskCommentModel>> getCommentList({required int task,required int page});
  Future<void> setTaskCommentsRead({required List<TaskCommentEntity?> comments});
  Future<TaskModel> setTaskStatus({
    int? id,
    required int status,
    required int task,
    int? resolution,
    required String comment,
    required DateTime createdTime,
    required DateTime manualTime,
    required bool timeChanging,
    required bool dateChanging,
    required bool commentChanging,
    required bool commentRequired,
  });
  Future<bool> setTaskFieldSelectionValue({required TasksFieldsModel taskField});
  Future<FileModel> addPictureTaskField({required int taskFieldId,required int pictureId});
  Future<FileModel> deletePictureTaskField({required int taskFieldId,required int pictureId});
  Future<TaskEntity> saveNewTask({required TaskEntity task});
  Future<PhoneEntity> addNewPhone({required String name});
  //Future<FileModel> addPictureTaskComment({required int taskCommentId,required int pictureId});
  Future<TaskCommentModel> addTaskComment({required TaskCommentModel comment});
}

class TaskRemoteDataSourcesImpl implements TaskRemoteDataSources
{
  final http.Client client;
  final SharedPreferences sharedPreferences;
  final DBProvider db;
  DateTime? from;
  DateTime? till;
  TaskRemoteDataSourcesImpl({required this.client,required this.sharedPreferences, required this.db});


  @override
  Future<List<TaskModel>> searchTask(String query) => _getTaskFromUrl(url: "https://mobifors111.mobiforce.ru/api2.0/get-tasks.php", page:0);

  @override
  Future<List<TaskModel>> getAllTask(int page) => _getTaskFromUrl(url: "https://mobifors111.mobiforce.ru/api2.0/get-tasks.php", page:page);

  @override
  Future<List<TemplateModel>>getAllTemplates(int page) async {
    return await db.getTemplatesListForMobile();
  }
  @override
  void setFilter({DateTime? dateFrom, DateTime? dateTill}) {
    //return await db.getTemplatesListForMobile();
    //void setFilter({DateTime? dateFrom, DateTime? dateTill})
    from = dateFrom;
    till = dateTill;
  }
  @override
  Future<List<int>> getTasksMounthCounter(DateTime from, DateTime till) async {
    int daysInSet=(till.millisecondsSinceEpoch-from.millisecondsSinceEpoch)~/86400000;
    int firstDayInSec=from.millisecondsSinceEpoch~/1000;
    List<int> counts = new List<int>.generate(daysInSet+1, (i) => 0);
    print("additional from ${from.millisecondsSinceEpoch} till ${till.millisecondsSinceEpoch}");
    final list = await db.getTasksMounthCounter(from, till);
    list.forEach((element) {
      int currentDay=(element-firstDayInSec)~/86400;
      if(currentDay>=0&&currentDay<=daysInSet)
        counts[currentDay]++;
    });

    print("daysInSet $daysInSet dates $list counts $counts");

    return counts;
  }
  @override
  Future<List<TaskLifeCycleNodeEntity>> getTaskStatusGraph(int ?id, int? lifecycle) async
  {
    return await db.getNextStatuses(id, lifecycle);
  }

  @override
  Future<UserSettingEntity>getUserSetting() async
  {
    //return await db.getGPSSetting();
    final int selfId = sharedPreferences.getInt("self_id")??0;
    String selfName = "";
    String selfLogin = "";
    print("self_id $selfId");
    if(selfId!=0){
      EmployeeModel? employee = await db.getEmployeeByServerId(selfId);
      selfName=employee?.name??"";
      selfLogin=employee?.login??"";
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    return new UserSettingEntity(gpsSchedule: await db.getGPSSetting(), appVersion: version, selfName: selfName, selfLogin: selfLogin);

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
    print('${directory.path}/photo_$id.jpg');
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
  Future<bool>saveFileDescription(FileModel file) async
  {
    //final f = await db.readFile(id);

    /*String domain=sharedPreferences.getString("domain")??"";
    String accessToken=sharedPreferences.getString("access_token")??"";

    print("remote file: ${f.serverId}");
    print("domain=$domain, access_token=$accessToken");
    final response = await http.get(Uri.parse("https://$domain/api2.0/get-file.php?id=${f.serverId}"),headers:{
      HttpHeaders.authorizationHeader: "key=\"$accessToken\"",
    });
    print("readFile load ${response.bodyBytes.toString()}");
    final directory = await getApplicationDocumentsDirectory();
    //final path = await _localPath;
    print('${directory.path}/photo_$id.jpg');
    final file = File('${directory.path}/photo_$id.jpg');
    //List<int> bytes = await picture.readAsBytes();
    if(response.bodyBytes!=null) {
      file.writeAsBytes(response.bodyBytes);
      f.downloaded=true;
      await db.updateFile(f);
    }*/
    //final FileModel f = FileModel(id: id, usn: usn, downloaded: downloaded, size: size, deleted: deleted)
    print("fieldId: ${file.parent?.id} fileId: ${file.id} desc:${file.description}");
    await db.updateFileDescription(file.parent.id, file.id,file.description??"");
    return true;
  }

  @override
  Future<FileModel> addPictureTaskField({required int taskFieldId,required int pictureId}) async
  {
    int id = await db.addPictureToTaskField(taskFieldId:taskFieldId,pictureId:pictureId);
    return FileModel(id: id, usn:0,downloaded: true, size:0, deleted: false, parent: TasksFieldsModel(id: taskFieldId, usn: 0, serverId: 0, valueRequired: false));
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
  Future<void> setTaskCommentsRead({required List<TaskCommentEntity?> comments}) async
  {
    return await db.setTaskCommentsRead(comments:comments);
    //return
      ;//FileModel(id: id, usn:0);
  }

  @override
  Future<TaskEntity> saveNewTask({required TaskEntity task}) async
  {
    (task as TaskModel).insertToDB(db);
    return task;
  }
  @override
  Future<PhoneEntity> addNewPhone({required String name}) async
  {
    PhoneModel phoneModel = PhoneModel(id: 0, usn: 0, name: name, temp: true);
    phoneModel.id = await phoneModel.insertToDB(db);
    return phoneModel;
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
    final int selfId = sharedPreferences.getInt("self_id")??0;
    int? internalSelfId = null;
    print("self_id $selfId");
    if(selfId!=0){
      internalSelfId = await db.getEmployeeIdByServerId(selfId);
    }
    return await db.getTask(id, internalSelfId);
  }
  @override
  Future<TaskModel> getTaskByExternalId(int externalId) async{
    final int selfId = sharedPreferences.getInt("self_id")??0;
    int? internalSelfId = null;
    print("self_id $selfId");
    if(selfId!=0){
      internalSelfId = await db.getEmployeeIdByServerId(selfId);
    }
    print("externalId: $externalId");
    int id = 0, counter=0;
    while(counter<10){
      id=await db.getTaskIdByServerId(externalId);
      print("id: $id");
      await Future.delayed(Duration(seconds: 1));
      if(id!=0)
        break;
      counter++;
    }
    return await db.getTask(id, internalSelfId);
  }
  @override
  Future<int> newTaskPicture() async{
    return await db.newFileRecord();
  }
  @override
  Future<TaskModel> setTaskStatus({
    int? id,
    required int status,
    required int task,
    int? resolution,
    required String comment,
    required DateTime createdTime,
    required DateTime manualTime,
    required bool timeChanging,
    required bool dateChanging,
    required bool commentChanging,
    required bool commentRequired,
  }) async{

    var date = new DateTime.now();
    //int d = (date.toUtc().millisecondsSinceEpoch/1000).toInt();
    TasksStatusesModel ts = TasksStatusesModel(
        id:id??0,
        usn:0,
        serverId: null,
        comment: comment,
        commentInput: commentChanging,
        commentRequired: commentRequired,
        timeChanging: timeChanging,
        dateChanging: dateChanging,
        resolution:resolution!=null?ResolutionModel(id: resolution, usn: 0, serverId: 0, name: "", resolutionGroup: <ResolutionGroupModel>[]):null,
        status:TaskStatusModel(serverId: 0,id:status, color:"", name:"", usn: 0),
        task:TaskModel(serverId:0,id:task,unreadedCommentCount:0),
        createdTime: createdTime.millisecondsSinceEpoch~/1000,
        manualTime: manualTime.millisecondsSinceEpoch~/1000,
        lat: 0.0, lon:0.0, dirty:true);
    print("resolution $resolution");
    await db.addStatusToTask(ts:ts,resolution: resolution,update_usn: true);
    return await db.getTask(task,null);
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
    int? fromSec=from!=null?from!.millisecondsSinceEpoch~/1000:null;
    int? tillSec=till!=null?till!.millisecondsSinceEpoch~/1000:null;
    print("fromSec $fromSec, tillSec $tillSec");
    return await db.getTasks(page, fromSec, tillSec);
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