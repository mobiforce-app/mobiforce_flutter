//import 'dart:html';

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobiforce_flutter/data/models/contractor_model.dart';
import 'package:mobiforce_flutter/data/models/file_model.dart';
import 'package:mobiforce_flutter/data/models/person_model.dart';
import 'package:mobiforce_flutter/data/models/phone_model.dart';
import 'package:mobiforce_flutter/data/models/task_life_cycle_model.dart';
import 'package:mobiforce_flutter/data/models/taskfield_model.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/data/models/tasksstatuses_model.dart';
import 'package:mobiforce_flutter/data/models/taskstatus_model.dart';
import 'package:mobiforce_flutter/data/models/template_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/taskfield_entity.dart';

import 'employee_model.dart';
import 'equipment_model.dart';

class TaskModel extends TaskEntity
{

  TaskModel({isChanged,required id,usn,required serverId,required unreadedCommentCount,name, status, contractor, address, statuses, checkList, propsList,
              author, employees,employee,equipment,phones,persons, template, deleted, addressFloor, addressInfo, addressPorch, addressRoom, lat, lon, externalLink,
              externalLinkName, createdAt, plannedVisitTime, plannedEndVisitTime,unreadedComments,lifecycle,live, notLoaded,loading
  }): super(
      isChanged:isChanged,
      id:id,
      usn:usn,
      serverId:serverId,
      deleted:deleted,
      live: live,
      notLoaded:notLoaded,
      loading:loading,
      name:name,
      contractor:contractor,
      address:address,
      status:status,
      statuses:statuses,
      propsList:propsList,
      checkList:checkList,
      author:author,
      equipment:equipment,
      employee:employee,
      employees:employees,
      phones:phones,
      persons:persons,
      template: template,
      addressFloor:addressFloor,
      addressInfo:addressInfo,
      addressPorch:addressPorch,
      addressRoom:addressRoom,
      lat:lat,
      lon:lon,
      externalLink:externalLink,
      externalLinkName:externalLinkName,
      createdAt:createdAt,
      plannedVisitTime:plannedVisitTime,
      plannedEndVisitTime:plannedEndVisitTime,
      unreadedComments:unreadedComments,
      lifecycle:lifecycle,
      unreadedCommentCount:unreadedCommentCount
  );

  Map<String, dynamic> toJson(){
    final DateFormat formatter = DateFormat('yyyy-MM-dd\THH:mm:ss');
    final map=Map<String, dynamic>();
    map["template"]=template?.toJson();
    map["employees"]=employees?.map((e) => e.toJson()).toList();
    map["employee"]=employees?[0].toJson();
    map["address"]=address;
    map["addressFloor"]=addressFloor;
    map["addressInfo"]=addressInfo;
    map["addressPorch"]=addressPorch;
    map["equipment"]=equipment?.toJson();
    map["addressRoom"]=addressRoom;
    map["plannedVisitTime"]=plannedVisitTime!=null?formatter.format(new DateTime.fromMillisecondsSinceEpoch(
        1000 * (plannedVisitTime ?? 0))):null;
    if(lat!=null)
        map["lat"]=lat;
    if(lon!=null)
      map["lon"]=lon;
    if(contractor!=null)
      map["contractor"]=contractor?.toJson();

    if(persons!=null)
    {
      List<Map<String, dynamic>> personsJSON=[];
      persons?.forEach((PersonModel element) {
        personsJSON.add(element.toJson());
      });
      map["person"]=personsJSON;
    }
    else
      map["person"]=[];
    map["phone"]=[];
    map["employee"]=employees?[0].toJson();
    List<Map<String, dynamic>> props=[];
    List<Map<String, dynamic>> checklist=[];
    propsList?.forEach((TasksFieldsModel element) {
      if(element.tab == 1)
        props.add(element.toJson());
      else if(element.tab == 2)
        checklist.add(element.toJson());

    });
    map["props"]=props;
    map["checklist"]=checklist;
    return map;
  }


  Map<String, dynamic> toMap(){
    final map=Map<String, dynamic>();
    map['name'] = name;
    map['usn'] = usn;
    map['not_loaded'] = notLoaded==true?1:0;
    map['deleted'] = deleted==true?1:0;
    map['external_id'] = serverId;
    map['contractor'] = contractor?.id;
    map['equipment'] = equipment?.id;
    map['lifecycle'] = lifecycle?.id;
    map['address'] = address;
    map['status'] = status?.id;
    //map['contractor'] = contractor?.id;
    map['author'] = author?.id;
    map['template'] = template?.id;
    map['address_floor'] = addressFloor;
    map['address_info'] = addressInfo;
    map['address_porch'] = addressPorch;
    map['address_room'] = addressRoom;
    map['lat'] = lat;
    map['lon'] = lon;
    map['external_link'] = externalLink;
    map['external_link_name'] = externalLinkName;
    map['created_at'] = createdAt;
    map['planned_visit_time'] = plannedVisitTime;
    map['planned_end_visit_time'] = plannedEndVisitTime;
    return map;
  }
  Future<int> insertToDB(db) async {
    Timeline.startSync('Task Insert To DB');

    if(status != null)
    {
      status?.id = await status!.insertToDB(db);
    }
    else
      id=0;

    if(contractor != null)
    {
      contractor?.id = await contractor!.insertToDB(db);
    }

    if(equipment != null)
    {
      equipment?.id = await equipment!.insertToDB(db);
    }

    if(template != null)
    {
      template?.id = await template!.insertToDB(db);
    }

    if(author != null)
    {
      author?.id = await author!.insertToDB(db);
    }
    if(lifecycle != null)
    {
      lifecycle?.id = await lifecycle!.insertToDB(db);
    }
    //print("lifecycle?.id ${lifecycle?.id}");

    //else
    //  id=0;
    //print ("INSERT Status id = $id");
    dynamic t = await db.insertTask(this);
    int taskId=t.id;
    //print ("db id == ${t.id}");
    if(taskId==0){
      taskId = await db.updateTaskByServerId(this);
      //print ("db id == ${taskId}");
    }
    Timeline.finishSync();
    Timeline.startSync('Task Employee');
    if(employees != null)
    {
      await db.deleteAllTaskEmployees(taskId);
      await Future.forEach(employees!,(EmployeeModel element) async {
        //print("employees Id = ${element.serverId}");
        //element.task = taskId;
        int employeeId = await element.insertToDB(db);
        if(employeeId>0){
          await db.addTaskEmployee(taskId,employeeId);
        }
      });
    }
    Timeline.finishSync();
    Timeline.startSync('Task Phone');
    if(phones != null)
    {
      await db.deleteAllTaskPhones(taskId);
      await Future.forEach(phones!,(PhoneModel element) async {
        //print("phones Id = ${element.serverId}");
        //element.task = taskId;
        element.taskId=taskId;
        int employeeId = await element.insertToDB(db);
        //if(employeeId>0){
        //  await db.addTaskEmployee(taskId,employeeId);
        //}
      });
    }
    Timeline.finishSync();
    Timeline.startSync('Task person');
    if(persons != null)
    {
      await db.deleteAllTaskPersons(taskId);
      await Future.forEach(persons!,(PersonModel element) async {
        //print("persons Id = ${element.serverId}");
        //element.task = taskId;
        element.taskId=taskId;
        int employeeId = await element.insertToDB(db);
        //if(employeeId>0){
        //  await db.addTaskEmployee(taskId,employeeId);
        //}
      });
    }
    Timeline.finishSync();
    Timeline.startSync('Task statuses');
    if(statuses != null)
    {
      await db.deleteAllTaskStatuses(taskId);
      await Future.forEach(statuses!,(TasksStatusesModel element) async {
        //print("status Id = ${element.serverId}");
        element.task.id = taskId;
        await element.insertToDB(db);
      });
    }
    else
      id=0;
    //print("checkList = ${checkList.toString()}");
    Timeline.finishSync();
    Timeline.startSync('Task checklist');
    //await db.deleteAllFieldsByTaskId(taskId);
    print("start check list");
    if(checkList != null)
    {
      await Future.forEach(checkList!,(TasksFieldsModel element) async {
        //print("TasksFieldsModel checkList Id = ${element.serverId}");
        element.task = TaskModel(id:taskId,serverId: 0,unreadedCommentCount: 0);
        await element.insertToDB(db);
        if (element.childrens!=null&&element.childrens!.length>0){
          await Future.forEach(element.childrens!,(TasksFieldsModel elementChildren) async {
            //print("TasksFieldsModel checkList elementChildren Id = ${elementChildren.serverId}");
            elementChildren.task = TaskModel(id:taskId,serverId: 0,unreadedCommentCount: 0);
            await elementChildren.insertToDB(db);
          });
        }
      });
    }
    else
      id=0;
    Timeline.finishSync();
    Timeline.startSync('Task props');

    print("start prop list");
    if(propsList != null)
    {
      await Future.forEach(propsList!,(TasksFieldsModel element) async {
        //print("TasksFieldsModel checkList Id = ${element.serverId}");
        element.task = TaskModel(id:taskId,serverId: 0,unreadedCommentCount: 0);
        await element.insertToDB(db);
        if (element.childrens!=null&&element.childrens!.length>0){
          await Future.forEach(element.childrens!,(TasksFieldsModel elementChildren) async {
            //print("TasksFieldsModel checkList elementChildren Id = ${elementChildren.serverId}");
            elementChildren.task = TaskModel(id:taskId,serverId: 0,unreadedCommentCount: 0);
            await elementChildren.insertToDB(db);
          });
        }
      });
    }
    else
      id=0;
    print("end prop list");
    Timeline.finishSync();
    /*if(propsList != null)
    {
      await Future.forEach(propsList!,(TasksFieldsModel element) async {
        print("TasksFieldsModel props Id = ${element.serverId}");
        element.task = taskId;
        await element.insertToDB(db);
      });
    }
    else
      id=0;*/
    //print("ObjectModel = ${object.toString()}");

    return taskId;
  }
  factory TaskModel.fromMap({
    required Map<String, dynamic> taskMap,
    required Map<String, dynamic>? statusMap,
    List<Map<String, dynamic>> statusesMap = const [],
    List<Map<String, dynamic>> tasksFieldsMap = const [],
    Map<int, dynamic> tasksFieldsSelectionValuesMap = const {},
    List<Map<String, dynamic>> taskPhoneMap = const [],
    List<Map<String, dynamic>> tasksFieldsFilesMap = const [],
    int unreadedComments = 0,
    int? internalSelfId
  })
  {
   // id = map['id'];
   // externalId = map['externalId'];
   // name = map['name'];
    Map<String,dynamic> lifeCycleMap={"id":taskMap['lifecycle_id'],"usn":taskMap['lifecycle_usn'],"name":taskMap['lifecycle_name'],"external_id":taskMap['lifecycle_external_id']};

    debugPrint("taskMap = ${taskMap.toString()}");
    //print("lifeCycleMap = ${lifeCycleMap.toString()}");

    //List<PhoneModel> phones = [];
    List<Map<String, dynamic>> phonesMap = [];
    Map<String, dynamic>? person = null;

    //PersonModel? p = null;//PersonModel(id: id, usn: usn, serverId: serverId, name: name)
    List<Map<String, dynamic>> persons = [];
    int personId=-1;
    print("taskPhoneMap $taskPhoneMap");
    taskPhoneMap.forEach((element) {
      if(element["person_id"]==null){
        phonesMap.add({"id":element["id"],"name":element["name"]});
      }
      else {
        if(person != null&&element["person_id"]!=person?["id"]){
          persons.add(person!);
          person = null;
        }
        if (person == null) {
          person =
          {"id": element["person_id"], "name": element["person_name"],"phone":<Map<String, dynamic>>[]};
          personId=element["person_id"];
        }
        if(element["person_id"]==personId){
          person?["phone"].add({"id":element["id"],"name":element["name"]});
        }
      }
      /*p = PersonModel.fromJson({"id"})
      if(element["person_id"]!=null) {

      }
      else{

      }*/

    });
    if(personId>0)
      persons.add(person!);
    print("persons ${persons}");
    //print("personsListMap: ${persons} $phonesMap");

    var contractor = ContractorModel.fromMap({
      "id":taskMap['contractor_id'],
      "usn":int.parse(taskMap['contractor_usn']??"0"),
      "external_id":taskMap['contractor_external_id']??0,
      "name":taskMap['contractor_name']??"",
      "parent": {
        "id":taskMap['contractor_parent_id'],
        "usn":int.parse(taskMap['contractor_parent_usn']??"0"),
        "external_id":taskMap['contractor_parent_external_id']??0,
        "name":taskMap['contractor_parent_name']??""
      }
    });
    //tasksFieldsFilesMap!: $tasksFieldsFilesMap");
    final List<FileModel> files = tasksFieldsFilesMap.map((files) => FileModel.fromMap(files)).toList();
    //print("files!: $files");
    var fieldList=tasksFieldsMap.map((tasksField) => TasksFieldsModel.fromMap(tasksField,tasksFieldsSelectionValuesMap)).toList();

    fieldList.forEach((element) {
      print("fieldList: ${element.id} ${element.taskField?.name} ${element.taskField?.id}");
      if(element.taskField?.type.value==TaskFieldTypeEnum.picture||element.taskField?.type.value==TaskFieldTypeEnum.signature){
        //print("TaskFieldTypeEnum.picture");
        files.forEach((file) {
          //print("TaskFieldTypeEnum.picture ${file.parent.id} && ${element.id}");
          if(file.parent?.id!=null&&file.parent.id==element.id) {
            element.fileValueList?.add(file);
            //print("add files ${file.parent.id} && ${element.id}");
          }
        });
      }
    });
        //var fieldList1=tasksFieldsFilesMap.map((tasksField) => TasksFieldsModel.fromMap(tasksField,{})).toList();

    //print("taskMap = ${taskMap.toString()}");
    return TaskModel(
        id: taskMap['id'],
        isChanged:false,
        usn: taskMap['usn'],
        employee:internalSelfId!=null?EmployeeModel(id: internalSelfId, usn: 0, serverId: 0, name: "", login: "", webAuth: false, mobileAuth: false):null,
        equipment:taskMap['equipment_id']!=null?EquipmentModel(id: taskMap['equipment_id']??0, usn: 0, serverId: 0, name: taskMap['equipment_name']??"",):null,
        author: taskMap['author']!=null?EmployeeModel(id: taskMap['author'], usn: 0, serverId: 0, name: taskMap['author_name']??"", login: "",   webAuth: false, mobileAuth: false):null,
        lat: double.tryParse(taskMap['lat']??"0"),
        lon: double.tryParse(taskMap['lon']??"0"),
        serverId: taskMap['external_id'],
        address: taskMap['address'],
        addressFloor: taskMap['address_floor'],
        addressPorch: taskMap['address_porch'],
        addressInfo: taskMap['address_info'],
        addressRoom: taskMap['address_room'],
        externalLink: taskMap['external_link'],
        externalLinkName: taskMap['external_link_name'],
        createdAt: taskMap['created_at'],
        plannedEndVisitTime: taskMap['planned_end_visit_time'],
        plannedVisitTime: taskMap['planned_visit_time'],
        notLoaded: taskMap['not_loaded']==1?true:false,
        name: taskMap['name'],
        contractor: contractor,
        unreadedCommentCount: taskMap['unreaded_comment_count']??0,
        template: TemplateModel(
            id: taskMap['template_id']??0,
            usn: 0,
            serverId: 0,
            name: taskMap['template_name']??"",
            enabledAddress: taskMap['template_enabled_address'] ==1?true:false,
            enabledComments: taskMap['template_enabled_comments']==1?true:false,
            enabledEquipment: taskMap['template_enabled_equipment'] ==1?true:false,
            enabledAddingNewPerson: taskMap['template_enabled_adding_new_person'] ==1 ?true:false,
            enabledAddingMultiplePerson:taskMap['template_enabled_adding_multiple_person']==1 ?true:false,
            requiredEquipment:taskMap['template_required_equipment']==1 ?true:false,
            requiredContractor:taskMap['template_required_contractor']==1 ?true:false,
        ),
        status:statusMap!=null?TaskStatusModel.fromMap(map:statusMap):null,
        statuses: statusesMap.map((tasksStatuses) => TasksStatusesModel.fromMap(tasksStatuses)).toList(),
        propsList: fieldList,
        unreadedComments:unreadedComments,
        lifecycle: lifeCycleMap['id']!=null?TaskLifeCycleModel.fromMap(lifeCycleMap):null,
        persons: persons.map((person) =>PersonModel.fromMap(person)).toList(),
        phones: phonesMap.map((phone) =>PhoneModel.fromMap(phone)).toList(),
    );
  }
  factory TaskModel.fromJson(Map<String, dynamic> json)
  {
    //print('jsonjson ${json[0]} ');
    //return TaskModel(id:0,externalId: 0, name: "");
    //print('json["task_statuses"] = ${json["task_statuses"]}');
    //debugPrint("ok1 ${json.toString()}");
    var propsList = json["props"]!=null?(json["props"] as List).map((taskStatus) => TasksFieldsModel.fromJson(taskStatus,1)).toList():<TasksFieldsModel>[];
    //print("ok2");
    var checkList = json["checklist"]!=null?(json["checklist"] as List).map((taskStatus) => TasksFieldsModel.fromJson(taskStatus,2)).toList():<TasksFieldsModel>[];
    propsList.addAll(checkList);
    //print("ok3 ${json["contractor"]} ${json["contractor"].runtimeType.toString()} ${json["contractor"].runtimeType.toString()=='_InternalLinkedHashMap<String, dynamic>'}");
    ContractorModel? contractor;
    print("json[person] ${json["person"]}");
    return TaskModel(
        id: 0,
        isChanged:false,
        usn: int.parse(json["usn"]??"0"),
        serverId: int.parse(json["id"]??"0"),
        name: json["name"]??"",
        deleted: json["deleted"]==1?true:false,
        live: json["live"]==1?true:false,
        unreadedCommentCount:0,
        contractor: json["contractor"].runtimeType.toString()=='_InternalLinkedHashMap<String, dynamic>'?ContractorModel.fromJson(json["contractor"]):null,
        equipment: json["equipment"].runtimeType.toString()=='_InternalLinkedHashMap<String, dynamic>'?EquipmentModel.fromJson(json["equipment"]):null,
        address: json["address"]??"",
        status:json["task_status"].runtimeType. toString()=='_InternalLinkedHashMap<String, dynamic>'?TaskStatusModel.fromJson(json["task_status"]):null,
        propsList:propsList,
        statuses:json["task_statuses"]!=null?(json["task_statuses"] as List).map((taskStatus) => TasksStatusesModel.fromJson(taskStatus)).toList():<TasksStatusesModel>[],
        author:json["author"].runtimeType.toString()=='_InternalLinkedHashMap<String, dynamic>'?EmployeeModel.fromJson(json["author"]):null,
        employees:json["employee"].runtimeType.toString()=='_InternalLinkedHashMap<String, dynamic>'?[EmployeeModel.fromJson(json["employee"])]:null,
        template:json["tasktemplate"].runtimeType.toString()=='_InternalLinkedHashMap<String, dynamic>'?TemplateModel.fromJson(json["tasktemplate"]):null,
        notLoaded:json["tasktemplate"].runtimeType.toString()=='_InternalLinkedHashMap<String, dynamic>'?false:true,
        phones:json["phone"]!=null?(json["phone"] as List).map((phone) => PhoneModel.fromJson(phone)).toList():<PhoneModel>[],
        persons:json["person"]!=null?(json["person"] as List).map((person) => PersonModel.fromJson(person)).toList():<PersonModel>[],
        addressFloor:json["addressFloor"]??"",
        addressInfo:json["addressInfo"]??"",
        addressPorch:json["addressPorch"]??"",
        addressRoom:json["addressRoom"]??"",
        lat: double.tryParse(json["lat"]??"0.0")??0.0,
        lon: double.tryParse(json["lon"]??"0.0")??0.0,
        externalLink:json["externalLink"],
        externalLinkName:json["externalLinkName"],
        createdAt:json["createdAt"]!=null?int.parse(json["createdAt"]??"0"):null,
        plannedVisitTime:json["plannedVisitTime"]!=null?int.parse(json["plannedVisitTime"]??"0"):null,
        plannedEndVisitTime:json["plannedEndVisitTime"]!=null?int.parse(json["plannedEndVisitTime"]??"0"):null,
        lifecycle: json["lifecycle"].runtimeType.toString()=='_InternalLinkedHashMap<String, dynamic>'?TaskLifeCycleModel.fromJson(json["lifecycle"]):null,
      //(json["emplo"] as List).map((taskStatus) => TasksStatusesModel.fromJson(taskStatus)).toList(),
    );
  }
  /*fromMap(Map<String, dynamic> map)
  {
    id = map['id'];
    name = map['name'];
  }*/

}