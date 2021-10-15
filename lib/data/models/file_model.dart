import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/data/models/resolution_model.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/domain/entity/file_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';

class FileModel extends FileEntity
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

  FileModel({required id, required usn,serverId,name, description, parent}): super(
      id:id,
      usn:usn,
      serverId:serverId,
      name:name,
      description: description,
      parent:parent,
  );

  Map<String, dynamic> toMap(){
    /*final map=Map<String, dynamic>();
    map['name'] = name;
    if(systemStatusId!=null)
      map['system_status_id'] = systemStatusId;
    map['usn'] = usn;
    map['external_id'] = serverId;
    map['color'] = color;
    return map;*/
    return {};
  }
  Future<int> insertToDB(DBProvider db) async {
    /*dynamic t = await db.insertTaskStatus(this);

    print ("db id == ${t.id}");
    if(t.id==0){
      t.id = await db.updateTaskStatusByServerId(this);
      print ("updateTaskStatusByServerId db id == ${t.id}");

    }
    return t.id;*/
    return 0;
  }
  factory FileModel.fromMap(Map<String, dynamic> map)
  {
   // id = map['id'];
   // externalId = map['externalId'];
   // name = map['name'];
    dynamic? parent = null;
    if(map['link_object_type']==1)
      parent=TasksFieldsModel(id: map['link_object'], usn: 0, serverId: map['field_external_id']??0);
    return FileModel(
        id: map['id'],
        usn: map['usn'],
        serverId: map['external_id'],
        description: map['description'],
        parent:parent
    );
  }
  factory FileModel.fromJson(Map<String, dynamic> json)
  {
    //print('jsonjson ${json[0]} ');
    //return TaskModel(id:0,externalId: 0, name: "");
    return FileModel(
        id: 0,
        usn: json["usn"]??0,
        serverId: int.parse(json["id"]??"0"),
        name: json["name"]??"",
        //systemStatusId: json['statusId']!=null?int.parse(json["statusId"]??"0"):null,
        //color: json["color"]??"",
    );
  }
  /*fromMap(Map<String, dynamic> map)
  {
    id = map['id'];
    name = map['name'];
  }*/

}