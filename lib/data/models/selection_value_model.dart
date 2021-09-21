import 'package:mobiforce_flutter/domain/entity/resolution_entity.dart';
import 'package:mobiforce_flutter/domain/entity/selection_value_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';

class SelectionValueModel extends SelectionValueEntity
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

  SelectionValueModel({required id,required serverId,required name,required deleted,required sorting, taskFieldId}): super(
      id:id,
      serverId:serverId,
      name:name,
      deleted:deleted,
      sorting:sorting,
      taskFieldId:taskFieldId,
      //client:client,
      //address:address
  );

  Map<String, dynamic> toMap(){
    final map=Map<String, dynamic>();
    map['name'] = name;
    map['external_id'] = serverId;
    map['sorting'] = sorting;
    map['deleted'] = deleted?1:0;
    map['task_field'] = taskFieldId;
    //map['client'] = client;
    //map['address'] = address;
    return map;
  }
  Future<int> insertToDB(db) async {
    dynamic t = await db.insertSelection(this);
    print ("insertSelection id == ${t.id}");
    return 0;
  }
  factory SelectionValueModel.fromMap(Map<String, dynamic> map)
  {
   // id = map['id'];
   // externalId = map['externalId'];
   // name = map['name'];
    return SelectionValueModel(
        id: map['id'],
        //usn: map['usn'],
        serverId: map['external_id'],
        deleted:map['deleted']==1?true:false,
        sorting:map['sorting'],
        taskFieldId:map['task_field'],
        //client: map['client'],
        //address: map['address'],
        name: map['name']
    );
  }
  factory SelectionValueModel.fromJson(Map<String, dynamic> json)
  {
    return SelectionValueModel(
        id: 0,
        serverId: int.parse(json["id"]??"0"),
        deleted: int.parse(json["deleted"]??"0")==1?true:false,
        sorting: int.parse(json["sorting"]??"0"),
        name: json["name"]??"",
    );
  }
  /*fromMap(Map<String, dynamic> map)
  {
    id = map['id'];
    name = map['name'];
  }*/

}