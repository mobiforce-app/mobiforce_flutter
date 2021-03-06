import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/data/models/selection_value_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskfield_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';

class TaskFieldModel extends TaskFieldEntity
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

  TaskFieldModel({required id,required usn,required serverId,required name, required type,selectionValues}): super(
      id:id,
      usn:usn,
      serverId:serverId,
      name:name,
      type:type,
      selectionValues:selectionValues
  );

  Map<String, dynamic> toMap(){


    final map=Map<String, dynamic>();

    TaskFieldType tft;
    map['type'] = type.id;
    map['name'] = name;
    map['usn'] = usn;
    map['external_id'] = serverId;
    //map['color'] = color;
    return map;
  }
  Future<int> insertToDB(DBProvider db) async {
    dynamic t = await db.insertTaskField(this);
    //print ("db id == ${t.id}");
    if(t.id==0){
      t.id = await db.updateTaskFieldByServerId(this);
      //print ("db id == ${t.toString()}");
    }
    //print("selectionValues = $selectionValues");
    if(selectionValues?.isNotEmpty??false)
    {
      await Future.forEach(selectionValues!,(SelectionValueModel element) async {
        //print("SelectionValueModel Id = ${element.serverId}");
        element.taskFieldId = t.id;
        await element.insertToDB(db);
      });
    }
    return t.id;
    //return 1;
  }
  factory TaskFieldModel.fromMap(Map<String, dynamic> map, List<Map<String, dynamic>> values)
  {
   // id = map['id'];
   // externalId = map['externalId'];
   // name = map['name'];
    //print("SelectionValueModel = $values");
    final List<SelectionValueModel> sv = values.map((selectionValue) => SelectionValueModel.fromMap(selectionValue)).toList();

    return TaskFieldModel(
        id: map['id'],
        usn: map['usn'],
        serverId: map['external_id'],
        type: TaskFieldType(map["type"]),
        name: map['name'],
        selectionValues: sv
    );
  }
  Map<String, dynamic> toJson(){
    final map=Map<String, dynamic>();
    map["id"]=serverId;
    return map;
  }
  factory TaskFieldModel.fromJson(Map<String, dynamic> json)
  {

    //print('jsonjsonTaskFieldModel ${json} ');
    //return TaskModel(id:0,externalId: 0, name: "");
    //if(json["selectionValues"]!=null)
    //{
      final List<SelectionValueModel> sv = json["selectionValues"]!=null?(json["selectionValues"] as List).map((selectionValue) => SelectionValueModel.fromJson(selectionValue)).toList():[];
    //print('jsonjsonTaskFieldModel ${json} ${json["selectionValues"].runtimeType} ');
    //}
    return TaskFieldModel(
        id: 0,
        usn: int.parse(json["usn"]??"0"),
        serverId: int.parse(json["id"]??"0"),
        name: json["name"]??"",
        type: TaskFieldType(int.parse(json["type"]??"0")),
        selectionValues: sv
        //color: json["color"]??"",
    );
  }
  /*fromMap(Map<String, dynamic> map)
  {
    id = map['id'];
    name = map['name'];
  }*/

}