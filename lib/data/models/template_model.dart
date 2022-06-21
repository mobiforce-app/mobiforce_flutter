import 'dart:developer';

import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/domain/entity/employee_entity.dart';
import 'package:mobiforce_flutter/domain/entity/resolution_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/template_entity.dart';

class TemplateModel extends TemplateEntity
{
  /*TaskModel({
    required id,
    required name,
    required address,
    required client,
    required subdivision
  }) : super(
      id:id,
      name:name,
      address:address,
      client:client,
      subdivision:subdivision
  );
  factory TaskModel.fromJson(Map<String, dynamic> json)
  {
    //print('jsonjson ${json[0]} ');
    return TaskModel(id: int.parse(json["id"]??0), name: json["name"]??"", address: json["address"]??"", client: json["client"]??"", subdivision: json["subdivision"]??"");
  }*/

  TemplateModel({
    required id,
    required usn,
    required serverId,
    required name,
    addFromMobile,
    color,
    propsList,
    enabledComments,
    enabledAddress,
    enabledEquipment,
    enabledAddingNewPerson,
    enabledAddingMultiplePerson,
    requiredEquipment,
    requiredContractor,

  }): super(
      id:id,
      usn:usn,
      serverId:serverId,
      name:name,
      color:color,
      propsList:propsList,
      addFromMobile:addFromMobile,
      enabledAddress: enabledAddress,
      enabledComments: enabledComments,
      enabledEquipment: enabledEquipment,
      enabledAddingNewPerson: enabledAddingNewPerson,
      enabledAddingMultiplePerson: enabledAddingMultiplePerson,
      requiredEquipment:requiredEquipment,
      requiredContractor:requiredContractor,


  );
  Map<String, dynamic> toJson(){
    final map=Map<String, dynamic>();
    map["name"]=name;
    map["id"]=serverId;
    return map;
  }
  Map<String, dynamic> toMap(){
    final map=Map<String, dynamic>();
    map['name'] = name;
    map['external_id'] = serverId;
    if(addFromMobile!=null)
      map['add_from_mobile'] = addFromMobile==true?1:0;
    map['enabled_address'] = enabledAddress==true?1:0;
    map['enabled_comments'] = enabledComments==true?1:0;
    map['enabled_equipment'] = enabledEquipment==true?1:0;
    map['enabled_adding_new_person'] = enabledAddingNewPerson==true?1:0;
    map['enabled_adding_multiple_person'] = enabledAddingMultiplePerson==true?1:0;
    map['required_equipment'] = requiredEquipment==true?1:0;
    map['required_contractor'] = requiredContractor==true?1:0;


    return map;
  }
  Future<int> insertToDB(DBProvider db) async {
    Timeline.startSync('Template Insert To DB');

    dynamic t = await db.insertTemplate(this);
    if(t.id==0){
      t = await db.updateTemplateByServerId(this);
      //print ("db id == ${t.toString()}");
    }

    //print ("template db id == ${t.id}");
    Timeline.finishSync();
    return t.id;
  }
  factory TemplateModel.fromMap(Map<String, dynamic> map)
  {
   // id = map['id'];
   // externalId = map['externalId'];
   // name = map['name'];
    return TemplateModel(
        id: map['id'],
        usn: map['usn'],
        serverId: map['external_id'],
        name: map['name'],
        enabledAddress: map['enabled_address'] == 1?true:false,
        enabledComments: map['enabled_comments'] == 1?true:false,
        addFromMobile: map['add_from_mobile'] == 1?true:false,
        enabledEquipment: map['enabled_equipment'] == 1?true:false,
        enabledAddingNewPerson: map['enabled_adding_new_person'] == 1?true:false,
        enabledAddingMultiplePerson:map['enabled_adding_multiple_person'] == 1?true:false,
        requiredEquipment:map['required_equipment'] == 1?true:false,
        requiredContractor:map['required_contractor'] == 1?true:false,

    );
  }
  factory TemplateModel.fromJson(Map<String, dynamic> json)
  {
    var propsList = json["props"]!=null?(json["props"] as List).map((taskStatus) => TasksFieldsModel.fromJson(taskStatus,1)).toList():<TasksFieldsModel>[];
    //print("ok2");
    var checkList = json["checklist"]!=null?(json["checklist"] as List).map((taskStatus) => TasksFieldsModel.fromJson(taskStatus,2)).toList():<TasksFieldsModel>[];
    propsList.addAll(checkList);

    print('TemplateModeljsonjson ${json} ');
    //return TaskModel(id:0,externalId: 0, name: "");
    return TemplateModel(
        id: 0,
        usn: json["usn"]??0,
        serverId: int.parse(json["id"]??0),
        name: json["name"]??"",
        color: json["color"],
        propsList:propsList,
        addFromMobile: json["addFromMobile"]==null?null:(json["addFromMobile"]==true?true:false),
        enabledAddress: json["enabledAddress"]==true?true:false,
        enabledComments: json["enabledComments"]==true?true:false,
        enabledEquipment: json["enabledEquipment"]==true?true:false,
        enabledAddingNewPerson: json["enabledAddingNewPerson"]==true?true:false,
        enabledAddingMultiplePerson: json["enabledAddingMultiplePerson"]==true?true:false,
        requiredEquipment: json["requiredEquipment"]==true?true:false,
        requiredContractor: json["requiredContractor"]==true?true:false,

    );
  }
  /*fromMap(Map<String, dynamic> map)
  {
    id = map['id'];
    name = map['name'];
  }*/

}