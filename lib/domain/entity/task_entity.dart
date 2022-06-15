import 'package:equatable/equatable.dart';
import 'package:mobiforce_flutter/data/models/contractor_model.dart';
import 'package:mobiforce_flutter/data/models/employee_model.dart';
import 'package:mobiforce_flutter/data/models/equipment_model.dart';
import 'package:mobiforce_flutter/data/models/person_model.dart';
import 'package:mobiforce_flutter/data/models/phone_model.dart';
import 'package:mobiforce_flutter/data/models/task_life_cycle_model.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/data/models/tasksstatuses_model.dart';
import 'package:mobiforce_flutter/data/models/taskstatus_model.dart';
import 'package:mobiforce_flutter/data/models/template_model.dart';
import 'package:mobiforce_flutter/domain/entity/taskstatus_entity.dart';

class TaskEntity extends Equatable{
  final bool? isChanged;
  int id;
  int serverId;
  bool? deleted;
  String? name;
  int? usn;
  ContractorModel? contractor;
  String? address;

  String? addressFloor;
  String? addressInfo;
  String? addressPorch;
  String? addressRoom;
  double? lat;
  double? lon;
  String? externalLink;
  String? externalLinkName;
  int unreadedCommentCount;
  int? createdAt;
  int? plannedVisitTime;
  int? plannedEndVisitTime;
  int? unreadedComments;
  TaskLifeCycleModel? lifecycle;
  //String? verificationRequired;
  //String? addressRoom;

 // String address;
 // String client;
 // String subdivision;
  TaskStatusModel? status;
  EmployeeModel? author;
  EquipmentModel? equipment;
  EmployeeModel? employee;
  TemplateModel? template;
  List<EmployeeModel>? employees;
  List<PhoneModel>? phones;
  List<PersonModel>? persons;
  List<TasksFieldsModel>? checkList;
  List<TasksFieldsModel>? propsList;
  List<TasksStatusesModel>? statuses;
  fromMap(Map<String, dynamic> map)
  {
    print("FROM MAP");
    id=0;
    usn=0;
    serverId=0;
    name="";
  }
  TaskEntity({
      this.isChanged,
      required this.id,
      this.usn,
      required this.serverId,
      required this.unreadedCommentCount,
      this.name,
      this.address,
      this.contractor,
      this.status,
      this.statuses,
      this.checkList,
      this.propsList,
      this.employees,
      this.equipment,
      this.template,
      this.author,
      this.employee,
      this.phones,
      this.persons,
      this.deleted,
    this.addressFloor,
    this.addressInfo,
    this.addressPorch,
    this.addressRoom,
    this.lat,
    this.lon,
    this.externalLink,
    this.externalLinkName,
    this.createdAt,
    this.plannedVisitTime,
    this.plannedEndVisitTime,
    this.unreadedComments,
    this.lifecycle

  });

  @override
  // TODO: implement props
  List<Object?> get props => [isChanged, id];
}