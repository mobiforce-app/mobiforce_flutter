import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/data/models/employee_model.dart';
import 'package:mobiforce_flutter/data/models/file_model.dart';
import 'package:mobiforce_flutter/data/models/selection_value_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/taskfield_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_comment_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskfield_entity.dart';
import 'package:mobiforce_flutter/domain/entity/tasksfields_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';

class TaskCommentModel extends TaskCommentEntity
{

  TaskCommentModel({required id,
    required usn,
    required task,
    required createdTime,
    lat,
    lon,
    required dirty,
    required serverId,
    message,
    author,
  }): super(
      id:id,
      usn:usn,
      serverId:serverId,
      task:task,
      dirty:dirty,
      createdTime:createdTime,
      message:message,
      author:author,
  );

  Map<String, dynamic> toMap(){


    final map=Map<String, dynamic>();

    map['usn'] = usn;
    map['external_id'] = serverId;
    map['created_at'] = createdTime;
    map['message'] = message;
    map["author"] = author.id;
    map["task"] = task.id;
    //map['element_id'] = elementLocalId;
    //map['task_field'] = taskFieldId;
    //map['sort'] = sort;
    //map['task'] = task?.id;
    //map['tasks_fields_tab'] = tab;

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
    print('getTaskByServerName: ${task.serverId}');
    task.id = await db.getTaskIdByServerId(task.serverId);
    print('author: ${author.serverId}');
    author.id = await author.insertToDB(db);
    print('author: ${author.id}');

    TaskCommentModel comment = await db.insertTaskComment(this);
    print ("db id == ${comment.id}");
    if(comment.id==0){
      comment = await db.updateTaskCommntByServerId(this);
      print ("db id == ${comment.toString()}");
    }

    return comment.id;
  }
  factory TaskCommentModel.fromMap(Map<String, dynamic> map)
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
    }*//*
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
*/
    print("TaskCommentModelMAP: $map");
    return TaskCommentModel(
        id: map['id'],
        usn: map['usn']??0,
        serverId: map['external_id'],
        createdTime: map['created_at'],
        dirty: false,
        message: map['message'],
        author: EmployeeModel.fromMap({"usn":0,"external_id":0, "id":map['author_id']??0, "name":map['author_name']??""}),
        //parentLocalId: map['parent_id'],
        //elementLocalId: map['element_id'],
        //sort: map['sort'],
        //tab:map['tasks_fields_tab'],
        //taskField:taskField,
        task:TaskModel(id: 0, serverId: 0),//nullTaskModel.fromMap(taskMap: {"external_id":0,"id":0}, statusMap: null),
        //selectionValue: selectionValue,
        //doubleValue:doubleValue,
        //stringValue:stringValue,
        //boolValue:boolValue,
        //fileValueList:<FileModel>[]
       // type: tft,
       // name: map['name']
    );
  }
  factory TaskCommentModel.fromJson(Map<String, dynamic> json)
  {
    /*print("json[fieldId] = ${json["fieldId"]}");
    var taskField = TaskFieldModel.fromJson(json["fieldId"]);

    print("optionList = ${json["value"].runtimeType}");
    var optionList = null;
    if(taskField.type.value==TaskFieldTypeEnum.optionlist) {
      try {
        optionList =
        SelectionValueModel.fromJson(json["value"]);
      }
      catch (e) {}
    }*/
    //int tabServerId=
    //if(tab)
    //print("TasksFieldsModel = ${json.toString()}|${taskField}");
    return TaskCommentModel(
      id: 0,
      usn: json["usn"]??0,
      //updateByToken: int.parse(json["id"]??"0"),
      serverId: int.parse(json["id"]??"0"),
      createdTime: int.parse(json['createdTime']??"0"),
      dirty: true,
      message: '${json['message']}',
      task: TaskModel.fromJson(json['task']),
      author: EmployeeModel.fromJson(json['author']),
      //elementLocalId: int.parse(json["element"]??"0"),
      //parentLocalId: int.parse(json["parent"]??"0"),
      //sort: int.parse(json["sort"]??"0"),
      //taskField: taskField,
      //selectionValue: optionList,
      //tabServerId:tabServerId,
      //doubleValue: taskField.type.value==TaskFieldTypeEnum.number?double.tryParse(json["value"]):null,
      //stringValue: taskField.type.value==TaskFieldTypeEnum.text?json["value"]:null,
      //name: json["name"]??"",
      //taskServerId: taskServerId,
      //task: 0,
    );
  }


}