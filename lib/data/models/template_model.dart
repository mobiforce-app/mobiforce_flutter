import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/domain/entity/employee_entity.dart';
import 'package:mobiforce_flutter/domain/entity/resolution_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/template_entity.dart';

class TemplateModel extends TemplateEntity
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

  TemplateModel({required id,required usn,required serverId,required name,}): super(
      id:id,
      usn:usn,
      serverId:serverId,
      name:name,
  );

  Map<String, dynamic> toMap(){
    final map=Map<String, dynamic>();
    map['name'] = name;
    map['external_id'] = serverId;
    return map;
  }
  Future<int> insertToDB(DBProvider db) async {
    dynamic t = await db.insertTemplate(this);
    if(t.id==0){
      t = await db.updateTemplateByServerId(this);
      print ("db id == ${t.toString()}");
    }

    print ("template db id == ${t.id}");
    return t.id;
  }
  factory TemplateModel.fromMap(Map<String, dynamic> map)
  {
   // id = map['id'];
   // externalId = map['externalId'];
   // name = map['name'];
    return TemplateModel(
        id: map['id'],
        usn: map['usn'],
        serverId: map['external_id'],
        name: map['name']
    );
  }
  factory TemplateModel.fromJson(Map<String, dynamic> json)
  {
    print('employeejsonjson ${json} ');
    //return TaskModel(id:0,externalId: 0, name: "");
    return TemplateModel(
        id: 0,
        usn: json["usn"]??0,
        serverId: int.parse(json["id"]??0),
        name: json["name"]??"",
    );
  }
  /*fromMap(Map<String, dynamic> map)
  {
    id = map['id'];
    name = map['name'];
  }*/

}