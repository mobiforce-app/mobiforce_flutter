import 'package:mobiforce_flutter/data/models/taskstatus_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';

class TaskModel extends TaskEntity
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

  TaskModel({required id,required usn,required serverId,required name, status, client, address}): super(
      id:id,
      usn:usn,
      serverId:serverId,
      name:name,
      client:client,
      address:address,
      status:status,
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
    print ("db id == ${t.id}");
    if(t.id==0){
      dynamic t1 = await db.updateTaskByServerId(this);
      print ("db id == ${t1.toString()}");

    }
    return 0;
  }
  factory TaskModel.fromMap(Map<String, dynamic> taskMap,Map<String, dynamic> statusMap)
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
    );
  }
  factory TaskModel.fromJson(Map<String, dynamic> json)
  {
    //print('jsonjson ${json[0]} ');
    //return TaskModel(id:0,externalId: 0, name: "");
    return TaskModel(
        id: 0,
        usn: json["usn"]??0,
        serverId: int.parse(json["id"]??0),
        name: json["name"]??"",
        client: json["client"]??"",
        address: json["address"]??"",
        status:TaskStatusModel.fromJson(json["task_status"])
    );
  }
  /*fromMap(Map<String, dynamic> map)
  {
    id = map['id'];
    name = map['name'];
  }*/

}