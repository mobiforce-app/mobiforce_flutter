import 'package:mobiforce_flutter/core/db/database.dart';
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
    required serverStatusId,
    required task,
    required createdTime,
    required manualTime,
    required lat,
    required name,
    required lon,
    required color,
    required statusId,
    required dirty,
  }): super(
      id: id,
      statusId: statusId,
      serverStatusId: serverStatusId,
      task: task,
      createdTime: createdTime,
      manualTime: manualTime,
      lat: lat,
      lon: lon,
      usn: usn,
      color: color,
      name: name,
      dirty: dirty,
  );

  Map<String, dynamic> toMap(){
    final map=Map<String, dynamic>();
    //map['name'] = name;
    //map['usn'] = usn;
    map['dirty'] = dirty?1:0;
    map['task'] = task;
    map['created_time'] = createdTime;
    map['manual_time'] = manualTime;
    map['lat'] = lat;
    map['lon'] = lon;
    map['external_id'] = serverId;
    map['task_status'] = statusId;
    //map['color'] = color;
    return map;
  }
  Future<int> insertToDB(DBProvider db) async {

    statusId = await db.getTaskStatusIdByServerId(serverStatusId);

    dynamic t = await db.insertTasksStatuses(this);

    print ("db id == ${t.id}");
    if(t.id==0){
      t.id = await db.updateTasksStatusesByServerId(this);
      print ("db id == ${t.toString()}");
    }
    return t.id;
  }
  factory TasksStatusesModel.fromMap(Map<String, dynamic> map)
  {
   // id = map['id'];
   // externalId = map['externalId'];
   // name = map['name'];
    print("TasksStatusesModel MAP ${map.toString()}");
    return TasksStatusesModel(
        id: map['id'],
        statusId: map['task_status'],
        usn: 0,//map['usn'],
        serverId: map['external_id'],
        serverStatusId: map['external_status_id']??0,
        task: map['task'],
        name: map['name']??"",
        createdTime: map['created_time'],
        manualTime: map['manual_time'],
        lat: double.tryParse(map['lat']),
        lon: double.tryParse(map['lon']),
        color: map['color'],
        dirty: map['dirty']==1?true:false,
        //color: map['color'],
        //name: map['name']
    );
  }
  factory TasksStatusesModel.fromJson(Map<String, dynamic> json)
  {
    print('jsonjson ${json} ');
    //return TaskModel(id:0,externalId: 0, name: "");
    return TasksStatusesModel(
        id: 0,
        statusId: 0,
        color: "",
        usn: json['usn']??0,
        name: json['name']??"",
        dirty: false,
        serverId: int.parse(json["id"]??"0"),
        serverStatusId: int.parse(json["statusId"]??"0"),
        createdTime: int.parse(json["time"]??"0"),
        manualTime: int.parse(json["time"]??"0"),
        lat: double.tryParse(json["lat"]??"0.0")??0.0,
        lon: double.tryParse(json["lon"]??"0.0")??0.0,
        task: 0,
    );
  }
  /*fromMap(Map<String, dynamic> map)
  {
    id = map['id'];
    name = map['name'];
  }*/

}