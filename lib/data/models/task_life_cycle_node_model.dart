import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/data/models/resolution_group_model.dart';
import 'package:mobiforce_flutter/data/models/resolution_model.dart';
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

  TaskLifeCycleNodeModel({required id,required usn,required serverId, required nextStatus, required currentStatus, lifeCycle, deleted, name, commentInput,
    commentRequired,
    timeChanging,
    dateChanging,
    forceStatusChanging,
    resolutionGroup,
    resolutions}): super(
      id:id,
      usn:usn,
      serverId:serverId,
      lifeCycle:lifeCycle,
      name:name,
     // needResolutionGroup:needResolutionGroup,
      nextStatus:nextStatus,
      currentStatus:currentStatus,
      //resolutionGroupServerId:resolutionGroupServerId,
      deleted:deleted,
      commentInput:commentInput,
      commentRequired:commentRequired,
      timeChanging:timeChanging,
      dateChanging:dateChanging,
      forceStatusChanging:forceStatusChanging,
      resolutionGroup:resolutionGroup,
      resolutions:resolutions,
  );

  Map<String, dynamic> toMap(){
    final map=Map<String, dynamic>();
    map['current_status'] = currentStatus.id;
    map['next_status'] = nextStatus.id;
    map['resolution_group'] = resolutionGroup?.id;
    map['usn'] = usn;
    map['life_cycle'] = lifeCycle;
    map['deleted'] = deleted==true?1:0;
    map['external_id'] = serverId;
    map['force_status_changing'] = forceStatusChanging==true?1:0;
    map['comment_input'] = commentInput==true?1:0;
    map['comment_required'] = commentRequired==true?1:0;
    map['time_changing'] = timeChanging==true?1:0;
    map['date_changing'] = dateChanging==true?1:0;
    return map;
  }
  Future<int> insertToDB(DBProvider db) async {

/*    if(element.currentStatus.id==0)
      element.currentStatus.id = await db.getTaskLifeCycleNodeByServerId(element.currentStatus.serverId);
    if(element.nextStatus.id==0)
      element.nextStatus.id = await db.getTaskLifeCycleNodeByServerId(element.nextStatus.serverId);
*/
  //print("insert");
    TaskStatusModel? tsCurrent = await db.getTaskStatusByServerId(currentStatus.serverId);
    TaskStatusModel? tsNext = await db.getTaskStatusByServerId(nextStatus.serverId);

    if((resolutionGroup?.serverId??0)>0)
      resolutionGroup?.id = await db.getResolutionGroupIdByServerId(resolutionGroup!.serverId);
    nextStatus.id = tsNext?.id??0;
    currentStatus.id = tsCurrent?.id??0;
    dynamic t = await db.insertTaskLifeCycleNode(this);
    //print ("LifeCycle node db id == ${t.id}");
    if(t.id==0){
      dynamic t1 = await db.updateTaskLifeCycleNodeByServerId(this);
      //print ("db id == ${t1.toString()}");
      return t1;
    }
    return t.id;
  }
  factory TaskLifeCycleNodeModel.fromMap({required Map<String, dynamic> map, List<Map<String, dynamic>> mapResolutions = const[]})
  {
   // id = map['id'];
   // externalId = map['externalId'];
   // name = map['name'];
    print("TaskLifeCycleNodeModel $map");
    return TaskLifeCycleNodeModel(
        id: map['id'],
        usn: map['usn'],
        serverId: map['external_id'],
        resolutionGroup: ResolutionGroupModel(id:map['resolution_group'],name: "", serverId: 0, usn: 0),
        nextStatus: TaskStatusModel(id:map['next_status_id'],name:map['next_status_name'],color:map['next_status_color'],serverId:0),
        currentStatus: TaskStatusModel(id:map['current_status_id'],serverId:0),
        commentInput: (map['comment_input'] == 1),
        commentRequired: (map['comment_required'] == 1),
        forceStatusChanging: (map['force_status_changing'] == 1),
        deleted: (map['deleted'] == 1),
        timeChanging: (map['time_changing'] == 1),
        dateChanging: (map['date_changing'] == 1),
        resolutions:mapResolutions.map((resolution) =>ResolutionModel.fromMap(map:resolution)).toList(),
      //nextStatusServerId: map['next'],
        //currentStatusServerId: map['current'],
    );
  }
  factory TaskLifeCycleNodeModel.fromJson(Map<String, dynamic> json)
  {
    //print('jsonjson ${json.toString()} ${json["id"].runtimeType}');
    //return TaskModel(id:0,externalId: 0, name: "");
    return TaskLifeCycleNodeModel(
      id: 0,
      //needResolutionGroup: 0,
      usn: int.tryParse(json["usn"]??"0"),
      serverId: int.tryParse(json["id"]??"0"),
      name: json["name"]??"",
      commentInput:json["commentInput"]??false,
      commentRequired:json["commentRequired"]??false,
      deleted:json["deleted"]??false,
      timeChanging:json["timeChanging"]??false,
      dateChanging:json["dateChanging"]??false,
      forceStatusChanging:json["forceStatusChanging"]??false,
      nextStatus: TaskStatusModel(id: 0, serverId:  int.tryParse(json["next"]??0)),
      currentStatus: TaskStatusModel(id: 0, serverId:  int.tryParse(json["current"]??0)),
      //resolutionGroupServerId:  int.tryParse(json["resolutionGroup"]??"0"),
      resolutionGroup: ResolutionGroupModel.fromJson(json["resolutionGroup"]),
    );

  }
  /*fromMap(Map<String, dynamic> map)
  {
    id = map['id'];
    name = map['name'];
  }*/

}