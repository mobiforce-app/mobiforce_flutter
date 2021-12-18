//enum TaskFieldType {undefined,text,number,checkbox,group,optionlist,picture}

import 'package:mobiforce_flutter/data/models/file_model.dart';
import 'package:mobiforce_flutter/data/models/selection_value_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
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
  TaskModel? task;
  TaskFieldModel? taskField;
  List<TasksFieldsModel>? childrens;
  SelectionValueModel? selectionValue;
  bool valueRequired;
  bool? boolValue;
  double? doubleValue;
  String? stringValue;
  List<FileModel>? fileValueList;
  int usn;
  int? tab;
  int? updateByToken;
  int? tabServerId;
  int? taskFieldId;

  TasksFieldsEntity({
    required this.id,
    required this.usn,
    this.taskFieldId,
    required this.serverId,
    this.elementLocalId,
    this.parentLocalId,
    this.sort,
    this.taskField,
    this.task,
    this.selectionValue,
    this.boolValue,
    required this.valueRequired,
    this.doubleValue,
    this.stringValue,
    this.fileValueList,
    this.tab,
    this.tabServerId,
    this.updateByToken,
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    usn=0;
    serverId=0;

  }
}