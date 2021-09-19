import 'package:mobiforce_flutter/data/models/tasksstatuses_model.dart';
import 'package:mobiforce_flutter/data/models/taskstatus_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';

class TaskModel extends TaskEntity
{

  TaskModel({required id,required usn,required serverId,required name, status, client, address, statuses}): super(
      id:id,
      usn:usn,
      serverId:serverId,
      name:name,
      client:client,
      address:address,
      status:status,
      statuses:statuses,
  );

  Map<String, dynamic> toMap(){
    final map=Map<String, dynamic>();
    map['name'] = name;
    map['usn'] = usn;
    map['external_id'] = serverId;
    map['client'] = client;
    map['address'] = address;
    map['status'] = status?.id;
    return map;
  }
  Future<int> insertToDB(db) async {
    if(status != null)
    {
      status?.id = await status!.insertToDB(db);
    }
    else
      id=0;
    print ("INSERT Status id = $id");
    dynamic t = await db.insertTask(this);
    int taskId=t.id;
    print ("db id == ${t.id}");
    if(taskId==0){
      taskId = await db.updateTaskByServerId(this);
      print ("db id == ${taskId}");
    }
    if(statuses != null)
    {
      await Future.forEach(statuses!,(TasksStatusesModel element) async {
        print("status Id = ${element.serverId}");
        element.task = taskId;
        await element.insertToDB(db);
      });
    }
    else
      id=0;

    return 0;
  }
  factory TaskModel.fromMap(Map<String, dynamic> taskMap,Map<String, dynamic> statusMap,List<Map<String, dynamic>> statusesMap)
  {
   // id = map['id'];
   // externalId = map['externalId'];
   // name = map['name'];
    print("statusMap = ${statusMap.toString()}");
    return TaskModel(
        id: taskMap['id'],
        usn: taskMap['usn'],
        serverId: taskMap['external_id'],
        client: taskMap['client'],
        address: taskMap['address'],
        name: taskMap['name'],
        status:TaskStatusModel.fromMap(statusMap),
        statuses: statusesMap.map((tasksStatuses) => TasksStatusesModel.fromMap(tasksStatuses)).toList()
    );
  }
  factory TaskModel.fromJson(Map<String, dynamic> json)
  {
    //print('jsonjson ${json[0]} ');
    //return TaskModel(id:0,externalId: 0, name: "");
    print('json["task_statuses"] = ${json["task_statuses"]}');
    return TaskModel(
        id: 0,
        usn: json["usn"]??0,
        serverId: int.parse(json["id"]??0),
        name: json["name"]??"",
        client: json["client"]??"",
        address: json["address"]??"",
        status:TaskStatusModel.fromJson(json["task_status"]),
        statuses:(json["task_statuses"] as List).map((taskStatus) => TasksStatusesModel.fromJson(taskStatus)).toList()
    );
  }
  /*fromMap(Map<String, dynamic> map)
  {
    id = map['id'];
    name = map['name'];
  }*/

}