import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';

class TemplateEntity{
  int id;
  int usn;
  int serverId;
  String name;
  String? color;
  List<TasksFieldsModel>? checkList;
  List<TasksFieldsModel>? propsList;

  TemplateEntity({
      required this.id, required this.serverId, required this.name, required this.usn, this.color, this.propsList,
  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    serverId=0;
    name="";
  }
}