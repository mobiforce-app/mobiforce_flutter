import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/data/models/resolution_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';

class TaskStatusModel extends TaskStatusEntity
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

  TaskStatusModel({required id,usn,required serverId,name, color,systemStatusId,resolutions}): super(
      id:id,
      usn:usn,
      serverId:serverId,
      name:name,
      color:color,
      systemStatusId:systemStatusId,
      resolutions:resolutions,
  );

  Map<String, dynamic> toMap(){
    final map=Map<String, dynamic>();
    map['name'] = name;
    if(systemStatusId!=null)
      map['system_status_id'] = systemStatusId;
    map['usn'] = usn;
    map['external_id'] = serverId;
    map['color'] = color;
    return map;
  }
  Future<int> insertToDB(DBProvider db) async {
    dynamic t = await db.insertTaskStatus(this);

    print ("db id == ${t.id}");
    if(t.id==0){
      t.id = await db.updateTaskStatusByServerId(this);
      print ("updateTaskStatusByServerId db id == ${t.id}");

    }
    return t.id;
  }
  factory TaskStatusModel.fromMap({required Map<String, dynamic> map, List<Map<String, dynamic>> mapResolutions = const[]})
  {
   // id = map['id'];
   // externalId = map['externalId'];
   // name = map['name'];
    return TaskStatusModel(
        id: map['id'],
        usn: map['usn'],
        serverId: map['external_id'],
        systemStatusId: map['system_status_id'],
        color: map['color'],
        name: map['name'],
        resolutions:mapResolutions.map((resolution) =>ResolutionModel.fromMap(map:resolution)).toList(),
    );
  }
  factory TaskStatusModel.fromJson(Map<String, dynamic> json)
  {
    //print('jsonjson ${json[0]} ');
    //return TaskModel(id:0,externalId: 0, name: "");
    return TaskStatusModel(
        id: 0,
        usn: json["usn"]??0,
        serverId: int.parse(json["id"]??"0"),
        name: json["name"]??"",
        systemStatusId: json['statusId']!=null?int.parse(json["statusId"]??"0"):null,
        color: json["color"]??"",
    );
  }
  /*fromMap(Map<String, dynamic> map)
  {
    id = map['id'];
    name = map['name'];
  }*/

}