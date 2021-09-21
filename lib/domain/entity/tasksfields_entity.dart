//enum TaskFieldType {undefined,text,number,checkbox,group,optionlist,picture}

import 'package:mobiforce_flutter/data/models/taskfield_model.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/domain/entity/taskfield_entity.dart';

class TasksFieldsEntity{
  int id;
  int serverId;
  int? elementLocalId;
  int? sort;
  int? parentLocalId;
  //int taskServerId;
  int? task;
  TaskFieldModel? taskField;
  List<TasksFieldsModel>? childrens;
  int usn;
  int? taskFieldId;

  TasksFieldsEntity({
      required this.id, required this.usn, taskFieldId, required this.serverId, this.elementLocalId,  this.parentLocalId, this.sort, this.taskField, this.task,
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    usn=0;
    serverId=0;

  }
}