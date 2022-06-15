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
    required localUsn,
    required usn,
    required task,
    required createdTime,
    lat,
    lon,
    required dirty,
    serverId,
    required mobile,
    message,
    readedTime,
    author,
    file,
  }): super(
      id:id,
      localUsn:localUsn,
      mobile:mobile,
      usn:usn,
      serverId:serverId,
      task:task,
      dirty:dirty,
      createdTime:createdTime,
      readedTime:readedTime,
      message:message,
      author:author,
      file:file,
  );

  Map<String, dynamic> toMap(){


    final map=Map<String, dynamic>();

    map['usn'] = localUsn;
    if(serverId!=null)
      map['external_id'] = serverId;
    map['created_at'] = createdTime;
    map['readed_at'] = readedTime;
    map['message'] = message;
    map['mobile'] = mobile?1:0;
    if(author!=null)
      map["author"] = author?.id;
    if(file!=null)
      map["file"] = file?.id;
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
    if(file!=null&&file?.id==0){
      file?.id = await file!.insertToDB(db);
    }
    TaskCommentModel comment = await db.insertTaskComment(this);
    //print ("db id == ${comment.id}");
    if(comment.id==0){
      comment = await db.updateTaskCommntByServerId(this);
      //print ("db id == ${comment.toString()}");
    }

    return comment.id;
  }
  factory TaskCommentModel.fromMap(Map<String, dynamic> map)
  {

    print("TaskCommentModelMAP: $map");
    TaskCommentModel comment = TaskCommentModel(
      id: map['id'],
      usn:0,
      localUsn: map['usn']??0,
      mobile: map['mobile']==1?true:false,
      serverId: map['external_id'],
      createdTime: map['created_at'],
      readedTime: map['readed_at'],
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
    if(map['file_id']!=null)
      comment.file = FileModel(id:map['file_id'],size:map['file_size']??0,usn: 0,downloaded: map['file_downloaded']==1?true:false,deleted: map['file_deleted']==1?true:false);

    return comment;
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
    print("TaskCommentModel comment  = ${json.toString()}");
    TaskCommentModel comment =  TaskCommentModel(
      id: 0,
      usn: json['usn']??0,
      localUsn: 0,
      //updateByToken: int.parse(json["id"]??"0"),
      mobile: json['mobile']==true?true:false,
      serverId: int.parse(json["id"]??"0"),
      createdTime: int.parse(json['createdTime']??"0"),
      readedTime: int.parse(json['readedTime']??"0"),
      dirty: true,
      message: '${json['message']}',
      task: TaskModel.fromJson(json['task']),
      author: EmployeeModel.fromJson(json['author']),
    );
    if(json['file']!=null)
      comment.file = FileModel.fromJson(json['file']);

    return comment;
  }


}