import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/data/models/task_life_cycle_node_model.dart';
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

  TaskLifeCycleModel({required id,required usn,required serverId,required name,node}): super(
      id:id,
      usn:usn,
      serverId:serverId,
      name:name,
      node:node,
  );

  Map<String, dynamic> toMap(){
    final map=Map<String, dynamic>();
    map['name'] = name;
    map['usn'] = usn;
    map['external_id'] = serverId;
    return map;
  }
  Future<int> insertToDB(DBProvider db) async {
    //if(resolutionGroupServerId>0)
    //  needResolutionGroup = await db.getResolutionGroupIdByServerId(resolutionGroupServerId);
    dynamic lifeCycle = await db.insertTaskLifeCycle(this);
    if(lifeCycle.id==0){
      lifeCycle.id = await db.updateTaskLifeCycleByServerId(this);
      print (" lifeCycledb id == ${lifeCycle.toString()}");
    }
    print (" lifeCycledb id == ${lifeCycle.toString()}");
    await Future.forEach(node!, (TaskLifeCycleNodeModel element) async {
      element.lifeCycle=lifeCycle.id;
      element.id = await element.insertToDB(db);
    });
    /*TaskStatusModel? tsCurrent = await db.getTaskStatusByServerId(currentStatusServerId);
    TaskStatusModel? tsNext = await db.getTaskStatusByServerId(nextStatusServerId);

    if(resolutionGroupServerId>0)
        needResolutionGroup = await db.getResolutionGroupIdByServerId(resolutionGroupServerId);
    nextStatus = tsNext?.id;
    currentStatus = tsCurrent?.id;
    dynamic t = await db.insertTaskLifeCycle(this);
    print ("db id == ${t.id}");
    if(t.id==0){
      dynamic t1 = await db.updateTaskLifeCycleByServerId(this);
      print ("db id == ${t1.toString()}");

    }*/
    return lifeCycle.id;
  }
  factory TaskLifeCycleModel.fromMap(Map<String, dynamic> map)
  {
   // id = map['id'];
   // externalId = map['externalId'];
   // name = map['name'];
    print("TaskLifeCycleModel ${map.toString()}");
    return TaskLifeCycleModel(
        id: map['id'],
        usn: map['usn'],
        serverId: map['external_id'],
        name: map['name'],
    );
  }
  factory TaskLifeCycleModel.fromJson(Map<String, dynamic> json)
  {
    print('jsonjson ${json.toString()} ');
    //return TaskModel(id:0,externalId: 0, name: "");
    final List<TaskLifeCycleNodeModel> nodes = json["nodes"]!=null?(json["nodes"] as List).map((selectionValue) => TaskLifeCycleNodeModel.fromJson(selectionValue)).toList():[];
    //print("${json["usn"].runtimeType} ${json["id"].runtimeType}");
    return TaskLifeCycleModel(
        id: 0,
        usn: int.tryParse(json["usn"]??"0"),
        serverId: int.tryParse(json["id"]??"0"),
        name: json["name"]??"",
        node: nodes,
    );
  }
  /*fromMap(Map<String, dynamic> map)
  {
    id = map['id'];
    name = map['name'];
  }*/

}