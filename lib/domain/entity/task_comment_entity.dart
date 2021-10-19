
import 'package:mobiforce_flutter/data/models/employee_model.dart';
import 'package:mobiforce_flutter/data/models/file_model.dart';
import 'package:mobiforce_flutter/data/models/task_model.dart';
import 'package:mobiforce_flutter/data/models/taskstatus_model.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';

class TaskCommentEntity{
  int id;
  int? serverId;
  TaskModel task;
  int createdTime;
  double? lat;
  double? lon;
  String? message;
  int localUsn;
  int usn;
  bool dirty;
  EmployeeModel? author;
  FileModel? file;

  TaskCommentEntity({
    required this.id,
    required this.localUsn,
    required this.usn,
    required this.task,
    required this.createdTime,
    this.lat,
    this.lon,
    required this.dirty,
    required this.serverId,
    this.message,
    this.author,
    this.file,
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    localUsn=0;
    serverId=0;

  }
}