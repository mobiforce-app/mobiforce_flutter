import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/data/models/resolution_group_model.dart';
import 'package:mobiforce_flutter/data/models/resolution_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/taskstatus_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/tasksstatuses_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';

class TasksStatusesModel extends TasksStatusesEntity
{
  TasksStatusesModel({
    required id,
    required usn,
    required serverId,
    //required serverStatusId,
    required task,
    required createdTime,
    required manualTime,
    required lat,
    //required name,
    required lon,
    //required color,
    //required statusId,
    required dirty,
    required status,
    comment,
    commentInput,
    commentRequired,
    timeChanging,
    dateChanging,
    resolution,
  }): super(
      id: id,
      // statusId: statusId,
      //serverStatusId: serverStatusId,
      serverId: serverId,
      task: task,
      createdTime: createdTime,
      manualTime: manualTime,
      lat: lat,
      lon: lon,
      usn: usn,
      //color: color,
      //name: name,
      dirty: dirty,
      status:status,
      comment:comment,
      commentInput:commentInput,
      commentRequired:commentRequired,
      timeChanging:timeChanging,
      dateChanging:dateChanging,
      resolution:resolution,
  );

  Map<String, dynamic> toMap(){
    final map=Map<String, dynamic>();
    //map['name'] = name;
    print("manualTime $manualTime");
    map['usn'] = usn;
    map['dirty'] = dirty?1:0;
    map['task'] = task.id;
    map['created_time'] = createdTime;
    map['manual_time'] = manualTime;
    map['comment'] = (comment??"");
    map['comment_required'] = (commentRequired??false)?1:0;
    map['comment_input'] = (commentInput??false)?1:0;
    map['time_changing'] = (timeChanging??false)?1:0;
    map['date_changing'] = (dateChanging??false)?1:0;
    if(resolution!=null)
      map['resolution'] = resolution?.id;
    map['lat'] = lat;
    map['lon'] = lon;
    if(serverId!=null)
      map['external_id'] = serverId;
    map['task_status'] = status.id;
    //map['color'] = color;
    //print ("task status map $map");
    return map;
  }
  Future<int> insertToDB(DBProvider db) async {

    //statusId = await db.getTaskStatusIdByServerId(serverStatusId);
    if(status.id==0)
      status.id = await status.insertToDB(db);

    if(resolution!=null && resolution?.id==0) {
      print("update resolution ${resolution?.serverId}");
      resolution?.id = await resolution!.insertToDB(db);
    }

    dynamic t = await db.insertTasksStatuses(this);
    //print ("status db id == ${t.id}");
    if(t.id==0){
      t = await db.updateTasksStatusesByServerId(this);
      //print ("db id == ${t.toString()}");
    }
    return t.id;
  }
  factory TasksStatusesModel.fromMap(Map<String, dynamic> map)
  {
   // id = map['id'];
   // externalId = map['externalId'];
   // name = map['name'];
    //print("TasksStatusesModel MAP ${map.toString()}");
    TaskStatusModel status = TaskStatusModel.fromMap(map:{"id":map["taskstatus_id"],"external_id":map["taskstatus_external_id"],"name":map['taskstatus_name'],"color":map['taskstatus_color']});

    return TasksStatusesModel(
        id: map['id'],
        //statusId: map['task_status'],
        usn: map['usn'],
        serverId: map['external_id'],
        //serverStatusId: map['external_status_id']??0,
        task: TaskModel.fromMap(taskMap: {"external_id":map['task_external_id']??0,"id":map['task_id']}, statusMap: null),
        //name: map['name']??"",
        createdTime: map['created_time'],
        manualTime: map['manual_time'],
        lat: double.tryParse(map['lat']),
        lon: double.tryParse(map['lon']),
        comment: map['comment'],
        commentInput: (map['comment_input'] == 1),
        commentRequired: (map['comment_required'] == 1),
        timeChanging: (map['time_changing'] == 1),
        dateChanging: (map['date_changing'] == 1),
        //color: map['color'],
        dirty: map['dirty']==1?true:false,
        status:status,
        resolution: map['resolution_id']!=null?ResolutionModel(id: map['resolution_id'],color: map['resolution_color'], usn: 0, serverId:  map['resolution_external_id'], name: map['resolution_name'], resolutionGroup: <ResolutionGroupModel>[]):null,
        //color: map['color'],
        //name: map['name']
    );
  }
  factory TasksStatusesModel.fromJson(Map<String, dynamic> json)
  {
    //print('TasksStatusesModeljsonjson ${json} ');
    //return TaskModel(id:0,externalId: 0, name: "");
    TaskStatusModel status = TaskStatusModel.fromJson({"id":json["taskStatusId"],"name":json['description'],"color":json['color']});
    print("resolution ${json["resolution"].toString()}");
    return TasksStatusesModel(
        id: 0,
        //statusId: 0,
        //color: "",
        usn: json['usn']??0,
        //name: json['name']??"",
        dirty: false,
        serverId: int.parse(json["id"]??"0"),
        //serverStatusId: int.parse(json["statusId"]??"0"),
        createdTime: int.parse(json["time"]??"0"),
       // manualTime: int.parse(json["time"]??"0"),
        lat: double.tryParse(json["lat"]??"0.0")??0.0,
        lon: double.tryParse(json["lon"]??"0.0")??0.0,
        task: TaskModel(id:0,serverId: 0),
        manualTime: json["manualTime"]!=null?int.parse(json["manualTime"]??"0"):int.parse(json["time"]??"0"),
        //lat: double.tryParse(map['lat']),
        //lon: double.tryParse(map['lon']),
        resolution: json["resolution"].runtimeType. toString()=='_InternalLinkedHashMap<String, dynamic>'?ResolutionModel.fromJson(json["resolution"]):null,
        comment: json['comment'],
        commentInput: json['commentInput']??false,
        commentRequired: json['commentRequired']??false,
        timeChanging: json['timeChanging']??false,
        dateChanging: json['dateChanging']??false,
        status: status,
    );
  }
  /*fromMap(Map<String, dynamic> map)
  {
    id = map['id'];
    name = map['name'];
  }*/

}