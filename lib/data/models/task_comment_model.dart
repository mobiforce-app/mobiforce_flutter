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
    serverId,
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
    if(serverId!=null)
      map['external_id'] = serverId;
    map['created_at'] = createdTime;
    map['message'] = message;
    if(author!=null)
      map["author"] = author?.id;
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
    print('author: ${author?.serverId}');
    author?.id = await author!.insertToDB(db);
    print('author: ${author?.id}');

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
        task:TaskModel(id: map['task_id'], serverId: map['task_external_id']),//nullTaskModel.fromMap(taskMap: {"external_id":0,"id":0}, statusMap: null),
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
      usn: 0,
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