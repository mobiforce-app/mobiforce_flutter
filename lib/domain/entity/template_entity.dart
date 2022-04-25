import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';

class TemplateEntity{
  int id;
  int usn;
  int serverId;
  String name;
  String? color;
  bool? enabledAddress;
  bool? enabledEquipment;
  bool? enabledAddingNewPerson;
  bool? enabledAddingMultiplePerson;
  bool? enabledComments;
  bool? requiredEquipment;
  bool? requiredContractor;
  List<TasksFieldsModel>? checkList;
  List<TasksFieldsModel>? propsList;

  TemplateEntity({
    required this.id,
    required this.serverId,
    required this.name,
    required this.usn,
    this.color,
    this.propsList,
    this.enabledAddress,
    this.enabledEquipment,
    this.enabledAddingNewPerson,
    this.enabledAddingMultiplePerson,
    this.enabledComments,
    this.requiredEquipment,
    this.requiredContractor,

  });
  fromMap(Map<String, dynamic> map)
  {
    id=0;
    serverId=0;
    name="";
  }
}