import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/core/error/exception.dart';
import 'package:mobiforce_flutter/core/error/failure.dart';
import 'package:mobiforce_flutter/core/platform/network_info.dart';
import 'package:mobiforce_flutter/data/datasources/authorization_data_sources.dart';
import 'package:mobiforce_flutter/data/datasources/authorization_remote_data_sources.dart';
import 'package:mobiforce_flutter/data/datasources/task_remote_data_sources.dart';
import 'package:mobiforce_flutter/data/datasources/updates_remote_data_sources.dart';
import 'package:mobiforce_flutter/data/models/authorization_model.dart';
import 'package:mobiforce_flutter/data/models/file_model.dart';
import 'package:mobiforce_flutter/data/models/resolution_model.dart';
import 'package:mobiforce_flutter/data/models/sync_model.dart';
import 'package:mobiforce_flutter/data/models/sync_status_model.dart';
import 'package:mobiforce_flutter/data/models/task_comment_model.dart';
import 'package:mobiforce_flutter/data/models/task_life_cycle_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/taskfield_model.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/data/models/tasksstatuses_model.dart';
import 'package:mobiforce_flutter/data/models/taskstatus_model.dart';
import 'package:mobiforce_flutter/domain/entity/authorization_entity.dart';
import 'package:mobiforce_flutter/domain/entity/sync_entity.dart';
import 'package:mobiforce_flutter/domain/entity/sync_status_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_comment_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskfield_entity.dart';
import 'package:mobiforce_flutter/domain/entity/tasksfields_entity.dart';
import 'package:mobiforce_flutter/domain/entity/tasksstatuses_entity.dart';
import 'package:mobiforce_flutter/domain/repositories/authirization_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/sync_repository.dart';
import 'package:mobiforce_flutter/domain/repositories/task_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/employee_model.dart';
class QueueToSync{
  final String type;
  final int usn;
  final dynamic object;
  QueueToSync({required this.type,required this.usn,required this.object,});
}
class SyncRepositoryImpl implements SyncRepository{
  final UpdatesRemoteDataSources updatesRemoteDataSources;
  final NetworkInfo networkInfo;
  final SharedPreferences sharedPreferences;
  final List<String> objectsType=["taskstatus","taskfield","tasklifecycle","task","resolution","taskcomment","employee"];
  final List<int> objectsTypeLastUpdateId=[];
  int syncObjectsTypeId=0;

  //final AuthorizationDataSource authorizationDataSource;
  int lastSyncTime=0;
  int localUSN=0;
  int localFileUSN=0;
///  int lastUpdateCount=0;
  String domain="";
  String accessToken="";
  bool fullSync=false;

  SyncRepositoryImpl({required this.networkInfo, required this.updatesRemoteDataSources, required this.sharedPreferences})
  {
    localUSN = sharedPreferences.getInt("local_usn")??0;
    localFileUSN = sharedPreferences.getInt("local_file_usn")??0;
    lastSyncTime = sharedPreferences.getInt("last_sync_time")??0;
    for(int i=0; i<objectsType.length;i++ ){
      objectsTypeLastUpdateId.add(sharedPreferences.getInt("last_update_count_${objectsType[i]}")??0);
    }
    domain=sharedPreferences.getString("domain")??"";
    accessToken=sharedPreferences.getString("access_token")??"";
    fullSync=sharedPreferences.getBool("full_sync")??false;
  }
  @override
  Future<bool>commit() async {
    await sharedPreferences.setInt("last_update_count_${objectsType[syncObjectsTypeId]}", objectsTypeLastUpdateId[syncObjectsTypeId]);
    return true;
  }
  @override
  int getLastSyncTime()  {
    //await sharedPreferences.setInt("last_update_count_${objectsType[syncObjectsTypeId]}", objectsTypeLastUpdateId[syncObjectsTypeId]);
    return lastSyncTime;
  }
  @override
  Future<bool>setComplete() async {
    print("complete fullSyncObjectsTypeId = $syncObjectsTypeId");
    syncObjectsTypeId++;
    //fullSyncUpdateId=0;
    //await sharedPreferences.setInt("full_sync_objects_type_id", fullSyncObjectsTypeId);
    //await sharedPreferences.setInt("full_sync_update_id", fullSyncUpdateId);
    if(syncObjectsTypeId>=objectsType.length) {
      syncObjectsTypeId=0;
      return true;
    }
    else
      return false;

  }

  @override
  bool isFullSyncStarted()
  {
    return sharedPreferences.getBool("full_sync")??false;
  }
  @override
  bool dbCheckVersion(int dbVersion)
  {
    print("dbVersion ## ${sharedPreferences.getInt("db_version")} $dbVersion");
    return dbVersion!=(sharedPreferences.getInt("db_version")??0);
  }
  @override
  Future<bool> dbSetVersion(int dbVersion) async
  {
    return await sharedPreferences.setInt("db_version",dbVersion);
  }


  @override
  void reloadUSN()
  {
    print("realoadUSN ${lastSyncTime}");
    localUSN = 0;
    localFileUSN = 0;
    //lastSyncTime = 0;
    //for(int i=0; i<objectsTypeLastUpdateId.length;i++ ){
    //  objectsTypeLastUpdateId[i]=0;
    //}
    lastSyncTime = sharedPreferences.getInt("last_sync_time")??0;
    print("realoadUSN ${lastSyncTime}");
    objectsTypeLastUpdateId.clear();
    for(int i=0; i<objectsType.length;i++ ){
      objectsTypeLastUpdateId.add(sharedPreferences.getInt("last_update_count_${objectsType[i]}")??0);
    }
    domain=sharedPreferences.getString("domain")??"";
    accessToken=sharedPreferences.getString("access_token")??"";
    print("objectsTypeLastUpdateId ${objectsTypeLastUpdateId.toString()}");
    //return null;
  }

  @override
  Future<Either<Failure, int>> sendUpdates(DBProvider db) async {
   // updatesRemoteDataSources.getDataList(
    int sendObjects=0;
    List<TasksFieldsEntity> tasksFiedls = await db.readTasksFieldsUpdates(localUSN);
    List<TasksStatusesEntity> tasksStatuses = await db.readTaskStatusUpdates(localUSN);
    List<TaskCommentEntity> tasksComments = await db.readTaskCommentsUpdates(localUSN);
    //List<TasksStatusesEntity> Files = await db.readFilesUpdates(localUSN);
    print("!!! ${tasksStatuses.length} ${tasksFiedls.length}");
    List<QueueToSync> all=[];
    tasksFiedls.forEach((element) {all.add(QueueToSync(type: "taskfield", usn:element.usn, object:element)); });
    tasksStatuses.forEach((element) {all.add(QueueToSync(type: "taskstatus", usn:element.usn, object:element)); });
    tasksComments.forEach((element) {all.add(QueueToSync(type: "comment", usn:element.localUsn, object:element)); });
    if(all.length==0){
      List<FileModel> files = await db.readFilesUpdates(localFileUSN);
      //files.forEach((element) {all.add(QueueToSync(type: "file", usn:element.usn, object:element)); });
      final directory = await getApplicationDocumentsDirectory();
      print("${files.toString()} $localFileUSN");
      await Future.forEach(files, (FileModel fileElement) async {
        //final fileElement = element.object as FileModel;
        print("fileid: ${fileElement.id}");
        localFileUSN = fileElement.usn;
        final Map<String, dynamic> send = {
          "localId": fileElement.id,
          "value":""
        };
        print('${directory.path}/photo_${fileElement.id}.jpg');
        //int id= await remoteDataSources.newTaskPicture();
        //final file = File('${directory.path}/photo_$id.jpg');

        int serverId = await updatesRemoteDataSources.sendFile(
            domain: domain,
            accessToken: accessToken,
            filename: '${directory.path}/photo_${fileElement.id}.jpg',
            localId: fileElement.id
        );
        if (serverId > 0)
          db.setFileServerID(fileElement.id, serverId);
        await sharedPreferences.setInt("local_file_usn", localFileUSN);
        sendObjects++;
        print("sendObjects2 $sendObjects");

      });
    }
    else {
      all.forEach((element) {
        print("send object: ${element.type},  usn: ${element.usn}, ");
      });
      all.sort((a, b) => a.usn.compareTo(b.usn));
      all = all.length > 30 ? all.sublist(0, 30) : all;
      /**/
      int error=0;
      for(final QueueToSync element in all){
      //await Future.forEach(all, (QueueToSync element) async {
        print("usn: ${element.usn}");
        if (element.type == "taskfield") {
          dynamic? val = null;
          final taskFieldElement = element.object as TasksFieldsModel;
          if (taskFieldElement.taskField?.type.value ==
              TaskFieldTypeEnum.optionlist) {
            print("serverId: ${taskFieldElement
                .serverId}, element.selectionValue?.serverId: ${taskFieldElement
                .selectionValue?.serverId}");
            val = taskFieldElement.selectionValue?.serverId.toString();
          }
          else if (taskFieldElement.taskField?.type.value ==
              TaskFieldTypeEnum.text) {
            val = taskFieldElement.stringValue;
          }
          else if (taskFieldElement.taskField?.type.value ==
              TaskFieldTypeEnum.checkbox) {
            val = taskFieldElement.boolValue;
          }
          else if (taskFieldElement.taskField?.type.value ==
              TaskFieldTypeEnum.number) {
            print("serverId: ${taskFieldElement
                .serverId}, element.selectionValue?.serverId: ${taskFieldElement
                .selectionValue?.serverId}");
            val =
            taskFieldElement.doubleValue != null ? taskFieldElement.doubleValue
                .toString() : null;
          }
          else if (taskFieldElement.taskField?.type.value ==
              TaskFieldTypeEnum.picture) {
            List<Map<String, dynamic>> picts = [];
            taskFieldElement.fileValueList?.forEach((FileModel element) {
              //Map<String,dynamic> pictEl={"localId":element.id};
              //if(element.serverId!=null)
              //  pictEl["id"]=element.serverId;
              picts.add({"id": element.serverId, "localId": element.id, "description": element.description, "deleted": element.deleted});
            });
            //print ("serverId: ${element.object.serverId}, element.selectionValue?.serverId: ${element.object.selectionValue?.serverId}");
            val = picts;
          }
          else if (taskFieldElement.taskField?.type.value ==
              TaskFieldTypeEnum.signature) {
            List<Map<String, dynamic>> picts = [];
            taskFieldElement.fileValueList?.forEach((FileModel element) {
              //Map<String,dynamic> pictEl={"localId":element.id};
              //if(element.serverId!=null)
              //pictEl["id"]=element.serverId;
              picts.add({"id": element.serverId, "localId": element.id, "deleted": element.deleted});
            });
            //print ("serverId: ${element.object.serverId}, element.selectionValue?.serverId: ${element.object.selectionValue?.serverId}");
            val = picts;
          }
          final Map<String, dynamic> send = {
            "id": element.object.serverId,
            "value": val
          };
          print("send: $send");
          int serverId = await updatesRemoteDataSources.sendUpdate(
              domain: domain,
              accessToken: accessToken,
              objectType: "taskfield",
              mapObjects: send
          );
          if (serverId > 0)
            ;
          else{
            error=1;
            break;
          }

          print("${serverId} OK");
        }
        else if (element.type == "comment") {
          final Map<String, dynamic> send = {
            //"id": element.object.task.id,
            "id": element.object.serverId,
            "task": element.object.task.serverId,
            "message": element.object.message,
            "file": element.object.file?.id,
            "createdTime": element.object.createdTime,
            "readedTime": element.object.readedTime
          };
          print("send: $send");
          int serverId = await updatesRemoteDataSources.sendUpdate(
              domain: domain,
              accessToken: accessToken,
              objectType: "comment",
              mapObjects: send
          );
          if (serverId > 0)
            db.setTasksCommentsServerID(element.object.id, serverId);
          else{
            error=2;
            break;
          }

          print("Status id: ${element.object.id}/${serverId} OK");
        }
        else if (element.type == "taskstatus") {
          //final Map<String,dynamic> send = {"id":element.object.serverId,"value":val};
          final TasksStatusesModel ts=element.object;
          final Map<String, dynamic> send = {
            "task": ts.task.serverId,
            "id":ts.serverId,
            "localId":ts.id,
            "statusId": ts.status.serverId,
            "createdTime": ts.createdTime,
            "manualTime": ts.manualTime,
            "dateChanging": ts.dateChanging,
            "timeChanging": ts.timeChanging,
            "comment": ts.comment,
            "commentInput": ts.commentInput,
            "commentRequired": ts.commentRequired,
            "resolution": ts.resolution?.serverId,
          };
          print("send: $send");
          int serverId = await updatesRemoteDataSources.sendUpdate(
              domain: domain,
              accessToken: accessToken,
              objectType: "taskstatus",
              mapObjects: send
          );
          print("serverId: $serverId");
          if (serverId > 0)
            db.setTasksStatusServerID(element.object.id, serverId);
          else{
            error=3;
            break;
          }
          print("Status id: ${element.object.id}/${serverId} OK");
        }
        sendObjects++;
        print("sendObjects1 $sendObjects");
        localUSN = element.usn;
        print("localUsn $localUSN");

        await sharedPreferences.setInt("local_usn", localUSN);

      };
      print("error code: $error");
      if(error!=0)
        return Left(ServerFailure());
    }

    print("sendObjects1 $sendObjects");
    return Right(sendObjects);
  }
  @override
  Future<bool> sendToken(String? fcmToken) async {
    if(fcmToken!=null) {
      final Map<String, dynamic> send = {
        "fcmToken": fcmToken,
      };
      print("send: $send");
      final int serverId = await updatesRemoteDataSources.sendUpdate(
        domain: domain,
        accessToken: accessToken,
        objectType: "fcmtoken",
        mapObjects: send,
      );
      return serverId == 1 ? true : false;
    }
    return false;
  }
  @override
  Future<Either<Failure, SyncModel>> getUpdates() async {

    List<dynamic> mapObject(json) {
      //dynamic t=TaskModel;
      if(objectsType[syncObjectsTypeId]=="task") {
        print ("type = task");
        return ((json as List).map((obj) => TaskModel.fromJson(obj)).toList());
      }
      if(objectsType[syncObjectsTypeId]=="tasklifecycle") {
        print ("type = task");
        return ((json as List).map((obj) => TaskLifeCycleModel.fromJson(obj)).toList());
      }
      if(objectsType[syncObjectsTypeId]=="taskstatus") {
        print ("type = taskstatus");
        return ((json as List).map((obj) => TaskStatusModel.fromJson(obj)).toList());
      }
      if(objectsType[syncObjectsTypeId]=="resolution"){
        print ("type = resolution");
        return ((json as List).map((obj) => ResolutionModel.fromJson(obj)).toList());
      }
      if(objectsType[syncObjectsTypeId]=="file"){
        print ("type = file");
        return ((json as List).map((obj) => FileModel.fromJson(obj)).toList());
      }
      if(objectsType[syncObjectsTypeId]=="taskfield"){
        print ("type = taskfield");
        return ((json as List).map((obj) => TaskFieldModel.fromJson(obj)).toList());
      }
      if(objectsType[syncObjectsTypeId]=="taskcomment"){
        print ("type = taskcomment");
        return ((json as List).map((obj) => TaskCommentModel.fromJson(obj)).toList());
      }
      if(objectsType[syncObjectsTypeId]=="employee"){
        print ("type = employee");
        return ((json as List).map((obj) => EmployeeModel.fromJson(obj)).toList());
      }

      return ((json as List).map((obj) => TaskModel.fromJson(obj)).toList());
    }
    print("lastSyncTime: $lastSyncTime");

    return await _getUpdates(()=> updatesRemoteDataSources.getDataList(
        domain: domain,
        accessToken:accessToken,
        objectType:objectsType[syncObjectsTypeId],
        lastSyncTime:lastSyncTime,
        lastUpdateCount:objectsTypeLastUpdateId[syncObjectsTypeId],
        mapObjects: mapObject
    ));
    //return Right(_r);
    //throw UnimplementedError();
  }
  Future<Either<Failure,SyncModel>> _getUpdates(Future<SyncModel> Function() getData) async {
      if(await networkInfo.isConnected){
        try{
          final remoteData = await getData();//remoteDataSources.searchTask(query);
          //if(remoteAuth.fullSync) {
            // await sharedPreferences.setBool("full_sync", true);
            // await sharedPreferences.setInt("last_sync_time", remoteAuth.lastSyncTime);
            // await sharedPreferences.setInt("last_update_count", remoteAuth.lastUpdateCount);
            // await sharedPreferences.setInt("full_sync_update_id", 0);
            // await sharedPreferences.setInt("full_sync_objects_type_id", 0);
          if(remoteData.dataList.isNotEmpty){
            //print("new fullSyncUpdateId = ${remoteData.dataList.last.usn}");
            objectsTypeLastUpdateId[syncObjectsTypeId]=remoteData.dataList.last.usn;
            //fullSyncUpdateId=remoteData.dataList.last.usn;
            //syncDataProgress=syncDataProgress+remoteData.dataList.length;
          }
          print("remoteAuth = ${remoteData.toString()}");
            return Right(remoteData);//SyncStatusModel(syncPhase: SyncPhase.fullSyncStart,progress: 0,complete: false,dataLength: 0));
          //}
          //else
          //  return Right(remoteAuth);//SyncStatusModel(syncPhase: SyncPhase.normalfullSyncComplete,progress: 0,complete: false,dataLength: 0));
        }
        on ServerException{
          //!!await Future.delayed(const Duration(seconds: 2), (){});
          return Left(ServerFailure());
        }
      }
      else
        return Left(NoInternetConnection());
    }
 /* @override
  Future <void> saveAuthorization(String token) async {
   //return await _getAuthrisationInfo(()=> remoteDataSources.firstLogin(domain: domain, login:login, pass:pass));
    //return Right(_r);
    //throw UnimplementedError();
    await authorizationDataSource.setString(key: "access_token", value: token);
    await authorizationDataSource.setInt(key: "start_sync_position", value: -1);
    await authorizationDataSource.setInt(key: "start_sync_length", value: -1);
    await authorizationDataSource.setInt(key: "last_update_count", value: 0);
    await authorizationDataSource.setInt(key: "last_sync_time", value: 0);

  }
  @override
  String?getAuthorization() {
   //return await _getAuthrisationInfo(()=> remoteDataSources.firstLogin(domain: domain, login:login, pass:pass));
    //return Right(_r);
    //throw UnimplementedError();
    //await authorizationDataSource.setString(key: "access_token", value: token);
    return authorizationDataSource.getString("access_token");
  }
*/

 /* @override
  Future<Either<Failure, List<TaskEntity>>> getAllTasks(int page) async {
   return await _getTasks(()=> remoteDataSources.getAllTask(page));
    //return Right(_r);
    //throw UnimplementedError();
  }
*/
  /*
  Future<Either<Failure,AuthorizationModel>> _getAuthrisationInfo(Future<AuthorizationModel> Function() getAuthrisationInfo) async {
    if(await networkInfo.isConnected){
      try{
        final remoteAuth = await getAuthrisationInfo();//remoteDataSources.searchTask(query);
        await saveAuthorization(remoteAuth.token);
        return Right(remoteAuth);
      }
      on ServerException{
        await Future.delayed(const Duration(seconds: 2), (){});
        return Left(ServerFailure());
      }
    }
    else
      return Left(ServerFailure());
  }*/
  /*Future<Either<Failure,<List<TaskEntity>>> _getTasks(Future<List<TaskEntity>> Function() getTasks) async  {

  }*/
/*
  Future<Either<Failure,<List<TaskEntity>>> _getTasks(Future<List<TaskEntity>> Function() getTasks) async  {
    if(await networkInfo.isConnected){
      try{
        final remoteTask = await getTasks();//remoteDataSources.searchTask(query);
        return Right(remoteTask);
      } on ServerFailure{
        return Left(ServerFailure());
      }
    }
    else
      return Left(ServerFailure());
 }

 */
}