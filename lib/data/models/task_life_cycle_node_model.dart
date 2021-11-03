import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/data/models/taskstatus_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_life_cycle_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_life_cycle_node_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';

class TaskLifeCycleNodeModel extends TaskLifeCycleNodeEntity
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

  TaskLifeCycleNodeModel({required id,required usn,required serverId, required needResolutionGroup, required nextStatus, required currentStatus, resolutionGroupServerId, lifeCycle, deleted, name}): super(
      id:id,
      usn:usn,
      serverId:serverId,
      lifeCycle:lifeCycle,
      name:name,
      needResolutionGroup:needResolutionGroup,
      nextStatus:nextStatus,
      currentStatus:currentStatus,
      resolutionGroupServerId:resolutionGroupServerId,
      deleted:deleted,
  );

  Map<String, dynamic> toMap(){
    final map=Map<String, dynamic>();
    map['current_status'] = currentStatus.id;
    map['next_status'] = nextStatus.id;
    map['need_resolution'] = needResolutionGroup;
    map['usn'] = usn;
    map['life_cycle'] = lifeCycle;
    map['deleted'] = deleted==true?1:0;
    map['external_id'] = serverId;
    return map;
  }
  Future<int> insertToDB(DBProvider db) async {

/*    if(element.currentStatus.id==0)
      element.currentStatus.id = await db.getTaskLifeCycleNodeByServerId(element.currentStatus.serverId);
    if(element.nextStatus.id==0)
      element.nextStatus.id = await db.getTaskLifeCycleNodeByServerId(element.nextStatus.serverId);
*/
    TaskStatusModel? tsCurrent = await db.getTaskStatusByServerId(currentStatus.serverId);
    TaskStatusModel? tsNext = await db.getTaskStatusByServerId(nextStatus.serverId);

    if(resolutionGroupServerId>0)
        needResolutionGroup = await db.getResolutionGroupIdByServerId(resolutionGroupServerId);
    nextStatus.id = tsNext?.id??0;
    currentStatus.id = tsCurrent?.id??0;
    dynamic t = await db.insertTaskLifeCycleNode(this);
    print ("LifeCycle node db id == ${t.id}");
    if(t.id==0){
      dynamic t1 = await db.updateTaskLifeCycleNodeByServerId(this);
      print ("db id == ${t1.toString()}");
      return t1;
    }
    return t.id;
  }
  factory TaskLifeCycleNodeModel.fromMap(Map<String, dynamic> map)
  {
   // id = map['id'];
   // externalId = map['externalId'];
   // name = map['name'];
    return TaskLifeCycleNodeModel(
        id: map['id'],
        usn: map['usn'],
        serverId: map['external_id'],
        needResolutionGroup: map['need_resolution'],
        nextStatus: TaskStatusModel(id:map['next_status'],serverId:0),
        currentStatus: TaskStatusModel(id:map['current_status'],serverId:0),
        //nextStatusServerId: map['next'],
        //currentStatusServerId: map['current'],
    );
  }
  factory TaskLifeCycleNodeModel.fromJson(Map<String, dynamic> json)
  {
    print('jsonjson ${json.toString()} ${json["id"].runtimeType}');
    //return TaskModel(id:0,externalId: 0, name: "");
    return TaskLifeCycleNodeModel(
      id: 0,
      needResolutionGroup: 0,
      usn: int.tryParse(json["usn"]??"0"),
      serverId: int.tryParse(json["id"]??"0"),
      name: json["name"]??"",
      nextStatus: TaskStatusModel(id: 0, serverId:  int.tryParse(json["next"]??0)),
      currentStatus: TaskStatusModel(id: 0, serverId:  int.tryParse(json["current"]??0)),
      resolutionGroupServerId:  int.tryParse(json["resolutionGroup"]??"0"),
    );

  }
  /*fromMap(Map<String, dynamic> map)
  {
    id = map['id'];
    name = map['name'];
  }*/

}