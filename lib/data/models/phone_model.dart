import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/domain/entity/employee_entity.dart';
import 'package:mobiforce_flutter/domain/entity/phone_entity.dart';
import 'package:mobiforce_flutter/domain/entity/resolution_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/template_entity.dart';

class PhoneModel extends PhoneEntity
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

  PhoneModel({required id,required usn,required serverId,required name, taskId, personId,}): super(
      id:id,
      usn:usn,
      serverId:serverId,
      name:name,
      taskId:taskId,
      personId:personId,
  );

  Map<String, dynamic> toMap(){
    final map=Map<String, dynamic>();
    map['name'] = name;
    map['external_id'] = serverId;
    map['task'] = taskId;
    map['person'] = personId;
    return map;
  }
  Future<int> insertToDB(DBProvider db) async {
    dynamic t = await db.insertPhone(this);
    if(t.id==0){
      t = await db.updatePhoneByServerId(this);
      print ("db id == ${t.toString()}");
    }

    print ("employee db id == ${t.id}");
    return t.id;
  }
  factory PhoneModel.fromMap(Map<String, dynamic> map)
  {
   // id = map['id'];
   // externalId = map['externalId'];
   // name = map['name'];
    return PhoneModel(
        id: map['id'],
        taskId: map['task'],
        usn: map['usn'],
        serverId: map['external_id'],
        name: map['name']
    );
  }
  factory PhoneModel.fromJson(Map<String, dynamic> json)
  {
    print('PhoneModeljsonjson ${json} ');
    //return TaskModel(id:0,externalId: 0, name: "");
    return PhoneModel(
        id: 0,
        usn: int.parse(json["usn"]??"0"),
        serverId: int.parse(json["id"]??"0"),
        name: json["name"]??"",
    );
  }
  /*fromMap(Map<String, dynamic> map)
  {
    id = map['id'];
    name = map['name'];
  }*/

}