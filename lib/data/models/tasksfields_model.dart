import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/data/models/file_model.dart';
import 'package:mobiforce_flutter/data/models/selection_value_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/taskfield_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskfield_entity.dart';
import 'package:mobiforce_flutter/domain/entity/tasksfields_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';

class TasksFieldsModel extends TasksFieldsEntity
{

  TasksFieldsModel({required id,required usn,required serverId,taskFieldId, elementLocalId,  parentLocalId, sort, taskField, task, selectionValue,boolValue,doubleValue,stringValue,fileValueList,tab, tabServerId, updateByToken, required valueRequired}): super(
      id:id,
      usn:usn,
      serverId:serverId,
      elementLocalId:elementLocalId,
      parentLocalId:parentLocalId,
      sort:sort,
      taskField:taskField,
      task:task,
      valueRequired:valueRequired,
      taskFieldId:taskFieldId,
      selectionValue:selectionValue,
      boolValue:boolValue,
      doubleValue:doubleValue,
      stringValue:stringValue,
      fileValueList:fileValueList,
      tabServerId:tabServerId,
      tab:tab,
      updateByToken:updateByToken,
  );

  Map<String, dynamic> toMap(){


    final map=Map<String, dynamic>();

    map['usn'] = usn;
    map['external_id'] = serverId;
    map['parent_id'] = parentLocalId;
    map['element_id'] = elementLocalId;
    map['task_field'] = taskFieldId;
    map['sort'] = sort;
    map['required'] = valueRequired?1:0;
    map['task'] = task?.id;
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

    //print("taskField: $taskField");
    //Timeline.startSync("insert taskfield");
    int? fieldId = await taskField?.insertToDB(db);
    //Timeline.finishSync();

    taskFieldId = fieldId;
    //print("$tabServerId");
//    Timeline.startSync("get by taskfield");
    tab = await db.getTasksFieldsTabIdByServerId(tabServerId);
//    Timeline.finishSync();

//    Timeline.startSync("inserttaskfields");
    TasksFieldsModel t = await db.insertTasksFields(this);
//    Timeline.finishSync();
//print ("db id == ${t.id}");
//    Timeline.startSync("updatetaskfields");
    if(t.id==0){
      t.id = await db.updateTasksFieldsByServerId(this);
      //print ("db id == ${t.toString()}");
    }
//    Timeline.finishSync();
    //print("putTaskField2taskSelectionValueRelation try to insert");

    if(t.selectionValue?.id==0)
    {
      t.selectionValue!.taskFieldId=fieldId;
      //print("insert selectionValue ${t.selectionValue?.name}");
      t.selectionValue?.id = await t.selectionValue!.insertToDB(db);
    }

    if(t.id>0)
    {

      //print("putTaskField2taskSelectionValueRelation1 try to insert ");

      //print("taskField.taskField?.type.value = ${t.taskField?.type.value}, ${t.id}, selection: ${t.selectionValue?.id}, string: ${t.stringValue}, double: ${t.doubleValue}");
      if(t.taskField?.type.value==TaskFieldTypeEnum.optionlist)
        await db.updateTaskFieldSelectionValue(taskFieldId:t.id,taskFieldSelectionValue:t.selectionValue?.id,update_usn: false);
      else if(t.taskField?.type.value==TaskFieldTypeEnum.text)
        await db.updateTaskFieldValue(taskFieldId:t.id,taskFieldValue:t.stringValue,update_usn: false);
      else if(t.taskField?.type.value==TaskFieldTypeEnum.number)
        await db.updateTaskFieldValue(taskFieldId:t.id,taskFieldValue:"${t.doubleValue}",update_usn: false);
      else if(t.taskField?.type.value==TaskFieldTypeEnum.picture)
      {
        //print("add files to base");
        await Future.forEach(fileValueList!, (FileModel element) async {
          element.parent=TasksFieldsModel(id: t.id, usn: 0, serverId: 0, valueRequired: false);
          //print("file extId ${element.serverId}");
          //element.
          int fmId  = await element.insertToDB(db);
          if(fmId==0&&(element.serverId??0)>0){
            print("filedb element.serverId ${element.serverId}");
            FileModel? f = await db.getFileByServerId(element.serverId!);
            if(f?.deleted==true)
              {
                element.id=f!.id;
                print("filedb update ${element.serverId}");
                await db.updateFile(element);

              }
          }

        });
      }
      else if(t.taskField?.type.value==TaskFieldTypeEnum.signature)
      {
        //print("add files to base");
        await Future.forEach(fileValueList!, (FileModel element) async {
          element.parent=TasksFieldsModel(id: t.id, usn: 0, serverId: 0, valueRequired: false);
          //print("file extId ${element.serverId}");
          //element.
          await element.insertToDB(db);

        });
      }
        //await db.updateTaskFieldValue(taskFieldId:t.id,taskFieldValue:"${t.doubleValue}",update_usn: false);
      else if(t.taskField?.type.value==TaskFieldTypeEnum.checkbox)
        await db.updateTaskFieldValue(taskFieldId:t.id,taskFieldValue:t.boolValue==true?"1":"0",update_usn: false);

      /*if(selectionValue!=null){
        print("putTaskField2taskSelectionValueRelation2 try to insert");
        await selectionValue!.putTaskField2taskSelectionValueRelation(db, t.id);
      }*/
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
    //print("TasksFieldsModel ${map.toString()}");
    var selectionValue = null;
    if(map['task_selection_value_id']!=null)
      selectionValue= SelectionValueModel.fromMap(
          {"sorting":0,
            "external_id":map['task_selection_value_external_id'],
            "id":map['task_selection_value_id'],
            "name":map['task_selection_value_name'],
          });
    //print("map['value'] ${map['value']} ${taskField.type.value}");
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
        valueRequired: map['required']==1?true:false,
        tab:map['tasks_fields_tab'],
        taskField:taskField,
        task:TaskModel.fromMap(taskMap: {"external_id":map['task_external_id']??0,"id":map['task_id']}, statusMap: null),
        selectionValue: selectionValue,
        doubleValue:doubleValue,
        stringValue:stringValue,
        boolValue:boolValue,
        fileValueList:<FileModel>[]
       // type: tft,
       // name: map['name']
    );
  }
  Map<String, dynamic> toJson(){
    final map=Map<String, dynamic>();
    print("map fields ${taskField?.serverId} ${taskField?.type.string} ${stringValue}");
    if(taskField?.type.value==TaskFieldTypeEnum.optionlist)
      map["value"]=selectionValue?.toJson();
    else if(taskField?.type.value==TaskFieldTypeEnum.text)
      map["value"]=stringValue;
    else if(taskField?.type.value==TaskFieldTypeEnum.number)
      map["value"]=doubleValue;
    else if(taskField?.type.value==TaskFieldTypeEnum.picture)
    ;
    else if(taskField?.type.value==TaskFieldTypeEnum.signature)
    ;//await db.updateTaskFieldValue(taskFieldId:t.id,taskFieldValue:"${t.doubleValue}",update_usn: false);
    else if(taskField?.type.value==TaskFieldTypeEnum.checkbox)
      map["value"]=boolValue;
    map["field"]=taskField?.toJson();
    return map;
  }
  factory TasksFieldsModel.fromJson(Map<String, dynamic> json,int? tabServerId)
  {
    print("json[fieldId] = ${json.toString()}");
    var taskField = TaskFieldModel.fromJson(json["fieldId"]);

    //print("optionList = ${json["value"].runtimeType}");
    var optionList = null;
    if(taskField.type.value==TaskFieldTypeEnum.optionlist) {
      try {
        optionList =
        SelectionValueModel.fromJson(json["value"]);
      }
      catch (e) {}
    }
    List<FileModel>? fileVL=[];
    //print("TasksFieldsModel = ${json.toString()})");
    //print("${taskField}");
    if(taskField.type.value==TaskFieldTypeEnum.picture) {
      //print('json["value"] ${json["value"]}');
      try {
        fileVL =
        (json["value"] as List).map((e) {
          //print('map file ${e.toString()}');
          return FileModel.fromJson({"id":e["pictureId"],"size":e["size"],"name":e["name"],"decription":e["decription"]});
        }).toList();
        //SelectionValueModel.fromJson(json["value"]);
      }
      catch (e) {}
    }
    if(taskField.type.value==TaskFieldTypeEnum.signature) {
      //print('json["value"] ${json["value"]}');
      try {
        fileVL =
        (json["value"] as List).map((e) {
          //print('map file ${e.toString()}');
          return FileModel.fromJson({"id":e["pictureId"],"size":e["size"],"name":e["name"],"decription":e["decription"]});
        }).toList();
        //SelectionValueModel.fromJson(json["value"]);
      }
      catch (e) {}
    }
    //int tabServerId=
    //if(tab)
    return TasksFieldsModel(
      id: 0,
      usn: json["usn"]??0,
      updateByToken: int.parse(json["id"]??"0"),
      serverId: int.parse(json["id"]??"0"),
      elementLocalId: int.parse(json["element"]??"0"),
      parentLocalId: int.parse(json["parent"]??"0"),
      sort: int.parse(json["sorting"]??"0"),
      valueRequired: json["required"]==true?true:false,
      taskField: taskField,
      selectionValue: optionList,
      tabServerId:tabServerId,
      boolValue: taskField.type.value==TaskFieldTypeEnum.checkbox?(json["value"]==true?true:false):null,
      doubleValue: taskField.type.value==TaskFieldTypeEnum.number?double.tryParse(json["value"]):null,
      stringValue: taskField.type.value==TaskFieldTypeEnum.text?json["value"]:null,
      fileValueList: fileVL,
      //name: json["name"]??"",
      //taskServerId: taskServerId,
      //task: 0,
    );
  }


}