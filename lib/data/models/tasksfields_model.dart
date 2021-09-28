import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/data/models/selection_value_model.dart';
import 'package:mobiforce_flutter/data/models/taskfield_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskfield_entity.dart';
import 'package:mobiforce_flutter/domain/entity/tasksfields_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';

class TasksFieldsModel extends TasksFieldsEntity
{

  TasksFieldsModel({required id,required usn,required serverId,taskFieldId, elementLocalId,  parentLocalId, sort, taskField, task, selectionValue,boolValue,doubleValue,stringValue,tab, tabServerId}): super(
      id:id,
      usn:usn,
      serverId:serverId,
      elementLocalId:elementLocalId,
      parentLocalId:parentLocalId,
      sort:sort,
      taskField:taskField,
      task:task,
      taskFieldId:taskFieldId,
      selectionValue:selectionValue,
      boolValue:boolValue,
      doubleValue:doubleValue,
      stringValue:stringValue,
      tabServerId:tabServerId,
      tab:tab,
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
    map['tasks_fields_tab'] = tab;

/*    switch(taskField?.type?.value)
    {
      case TaskFieldTypeEnum.number: map['value']="$doubleValue";break;
      case TaskFieldTypeEnum.text: map['value']=stringValue;break;
      case TaskFieldTypeEnum.checkbox: map['value']=(boolValue==true?1:0);break;
      default: map['value']="";
    }
  */  return map;
  }
  Future<int> insertToDB(DBProvider db) async {

    print("taskField: $taskField");
    int? fieldId = await taskField?.insertToDB(db);
    taskFieldId = fieldId;
    print("$tabServerId");
    tab = await db.getTasksFieldsTabIdByServerId(tabServerId);

    dynamic t = await db.insertTasksFields(this);
    print ("db id == ${t.id}");
    if(t.id==0){
      t.id = await db.updateTasksFieldsByServerId(this);
      print ("db id == ${t.toString()}");
    }
    print("putTaskField2taskSelectionValueRelation try to insert");

    if(t.id>0)
    {
      print("putTaskField2taskSelectionValueRelation1 try to insert");
      if(selectionValue!=null){
        print("putTaskField2taskSelectionValueRelation2 try to insert");
        await selectionValue!.putTaskField2taskSelectionValueRelation(db, t.id);
      }
    }
    return t.id;
    return 1;
  }
  factory TasksFieldsModel.fromMap(Map<String, dynamic> map, Map<int, dynamic> mapListValues)
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

    final taskField=TaskFieldModel.fromMap(taskFieldMap,mapListValues[taskFieldMap["id"]]);
    print("TasksFieldsModel ${map.toString()}");
    var selectionValue = null;
    if(map['task_selection_value_id']!=null)
      selectionValue= SelectionValueModel.fromMap(
          {"sorting":0,
            "external_id":map['task_selection_value_external_id'],
            "id":map['task_selection_value_id'],
            "name":map['task_selection_value_name'],
          });
    print("map['value'] ${map['value']} ${taskField.type.value}");
    double? doubleValue=(taskField.type.value==TaskFieldTypeEnum.number&&map['value']!=null?double.tryParse(map['value']):null);
    String? stringValue=(taskField.type.value==TaskFieldTypeEnum.text?map['value']:null);
    bool? boolValue=(taskField.type.value==TaskFieldTypeEnum.checkbox&&map['value']=="1"?true:false);

    return TasksFieldsModel(
        id: map['id'],
        usn: map['usn']??0,
        serverId: map['external_id'],
        parentLocalId: map['parent_id'],
        elementLocalId: map['element_id'],
        sort: map['sort'],
        tab:map['tasks_fields_tab'],
        taskField:taskField,
        selectionValue: selectionValue,
        doubleValue:doubleValue,
        stringValue:stringValue,
        boolValue:boolValue
       // type: tft,
       // name: map['name']
    );
  }
  factory TasksFieldsModel.fromJson(Map<String, dynamic> json,int? tabServerId)
  {
    print("json[fieldId] = ${json["fieldId"]}");
    var taskField = TaskFieldModel.fromJson(json["fieldId"]);

    print("optionList = ${json["value"].runtimeType}");
    var optionList = null;
    if(taskField.type.value==TaskFieldTypeEnum.optionlist) {
      try {
        optionList =
        SelectionValueModel.fromJson(json["value"]);
      }
      catch (e) {}
    }
    //int tabServerId=
    //if(tab)
    print("TasksFieldsModel = ${json.toString()}|${taskField}");
    return TasksFieldsModel(
      id: 0,
      usn: json["usn"]??0,
      serverId: int.parse(json["id"]??"0"),
      elementLocalId: int.parse(json["element"]??"0"),
      parentLocalId: int.parse(json["parent"]??"0"),
      sort: int.parse(json["sort"]??"0"),
      taskField: taskField,
      selectionValue: optionList,
      tabServerId:tabServerId,
      //name: json["name"]??"",
      //taskServerId: taskServerId,
      //task: 0,
    );
  }


}