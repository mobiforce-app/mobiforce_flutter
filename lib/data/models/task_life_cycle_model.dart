import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/data/models/taskstatus_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_life_cycle_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';

class TaskLifeCycleModel extends TaskLifeCycleEntity
{
  /*TaskModel({
    required id,
    required name,
    required address,
    required client,
    required subdivision
  }) : super(
      id:id,
      name:name,
      address:address,
      client:client,
      subdivision:subdivision
  );
  factory TaskModel.fromJson(Map<String, dynamic> json)
  {
    //print('jsonjson ${json[0]} ');
    return TaskModel(id: int.parse(json["id"]??0), name: json["name"]??"", address: json["address"]??"", client: json["client"]??"", subdivision: json["subdivision"]??"");
  }*/

  TaskLifeCycleModel({required id,required usn,required serverId,required currentStatusServerId, required nextStatusServerId, required needResolution, nextStatus, currentStatus}): super(
      id:id,
      usn:usn,
      serverId:serverId,
      currentStatusServerId:currentStatusServerId,
      nextStatusServerId:nextStatusServerId,
      needResolution:needResolution,
      nextStatus:nextStatus,
      currentStatus:currentStatus,

  );

  Map<String, dynamic> toMap(){
    final map=Map<String, dynamic>();
    map['current_status'] = currentStatus;
    map['next_status'] = nextStatus;
    map['need_resolution'] = needResolution;
    map['usn'] = usn;
    map['external_id'] = serverId;
    return map;
  }
  Future<int> insertToDB(DBProvider db) async {
    TaskStatusModel? tsCurrent = await db.getTaskStatusByServerId(currentStatusServerId);
    TaskStatusModel? tsNext = await db.getTaskStatusByServerId(nextStatusServerId);
    nextStatus = tsNext?.id;
    currentStatus = tsCurrent?.id;
    dynamic t = await db.insertTaskLifeCycle(this);
    print ("db id == ${t.id}");
    if(t.id==0){
      dynamic t1 = await db.updateTaskLifeCycleByServerId(this);
      print ("db id == ${t1.toString()}");

    }
    return 0;
  }
  factory TaskLifeCycleModel.fromMap(Map<String, dynamic> map)
  {
   // id = map['id'];
   // externalId = map['externalId'];
   // name = map['name'];
    return TaskLifeCycleModel(
        id: map['id'],
        usn: map['usn'],
        serverId: map['external_id'],
        needResolution: map['resolution'],
        nextStatus: map['next_status'],
        currentStatus: map['current_status'],
        nextStatusServerId: map['next'],
        currentStatusServerId: map['current'],
    );
  }
  factory TaskLifeCycleModel.fromJson(Map<String, dynamic> json)
  {
    print('jsonjson ${json.toString()} ');
    //return TaskModel(id:0,externalId: 0, name: "");
    return TaskLifeCycleModel(
        id: 0,
        usn: json["usn"]??0,
        serverId: json["id"]??0,
        nextStatusServerId: json["next"]??0,
        currentStatusServerId: json["current"]??0,
        needResolution: json["resolution"]??0,
    );
  }
  /*fromMap(Map<String, dynamic> map)
  {
    id = map['id'];
    name = map['name'];
  }*/

}