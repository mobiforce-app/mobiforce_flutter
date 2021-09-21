import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/data/models/taskfield_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskfield_entity.dart';
import 'package:mobiforce_flutter/domain/entity/tasksfields_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';

class TasksFieldsModel extends TasksFieldsEntity
{

  TasksFieldsModel({required id,required usn,required serverId,taskFieldId, elementLocalId,  parentLocalId, sort, taskField, task, }): super(
      id:id,
      usn:usn,
      serverId:serverId,
      elementLocalId:elementLocalId,
      parentLocalId:parentLocalId,
      sort:sort,
      taskField:taskField,
      task:task,
      taskFieldId:taskFieldId,
      //taskServerId:taskServerId,
      //name:name,
      //task:task,
  );

  Map<String, dynamic> toMap(){


    final map=Map<String, dynamic>();

    map['usn'] = usn;
    map['external_id'] = serverId;
    map['parent_id'] = parentLocalId;
    map['element_id'] = elementLocalId;
    map['task_field'] = taskFieldId;
    map['sort'] = sort;
    map['task'] = task;
    //map['color'] = color;
    return map;
  }
  Future<int> insertToDB(DBProvider db) async {

    print("taskField: $taskField");
    int? fieldId = await taskField?.insertToDB(db);
    taskFieldId = fieldId;
    dynamic t = await db.insertTasksFields(this);
    print ("db id == ${t.id}");
    if(t.id==0){
      t.id = await db.updateTasksFieldsByServerId(this);
      print ("db id == ${t.toString()}");
    }
    return t.id;
    return 1;
  }
  factory TasksFieldsModel.fromMap(Map<String, dynamic> map)
  {
   // id = map['id'];
   // externalId = map['externalId'];
   // name = map['name'];
    /*TaskFieldType tft;
    switch(map["type"]){
      case 1: tft=TaskFieldType.text; break;
      case 2: tft=TaskFieldType.number; break;
      case 3: tft=TaskFieldType.checkbox; break;
      case 4: tft=TaskFieldType.group; break;
      case 5: tft=TaskFieldType.optionlist; break;
      case 6: tft=TaskFieldType.picture; break;
      default: tft=TaskFieldType.undefined;
    }*/
    Map<String, dynamic> taskFieldMap={
      'id':map['field_id'],
      'name':map['field_name'],
      'external_id':map['field_external_id'],
      'usn':map['field_usn'],
      'type':map['field_type'],
    };
    final taskField=TaskFieldModel.fromMap(taskFieldMap);
    print("TasksFieldsModel ${map.toString()}");
    return TasksFieldsModel(
        id: map['id'],
        usn: map['usn']??0,
        serverId: map['external_id'],
        parentLocalId: map['parent_id'],
        elementLocalId: map['element_id'],
        sort: map['sort'],
        taskField:taskField
       // type: tft,
       // name: map['name']
    );
  }
  factory TasksFieldsModel.fromJson(Map<String, dynamic> json)
  {
    var taskField = TaskFieldModel.fromJson(json["fieldId"]);
   print("TasksFieldsModel = ${json.toString()}|${taskField}");
   return TasksFieldsModel(
        id: 0,
        usn: json["usn"]??0,
        serverId: int.parse(json["id"]??"0"),
        elementLocalId: int.parse(json["element"]??"0"),
        parentLocalId: int.parse(json["parent"]??"0"),
        sort: int.parse(json["sort"]??"0"),
        taskField: taskField
        //name: json["name"]??"",
        //taskServerId: taskServerId,
        //task: 0,
    );
  }

}