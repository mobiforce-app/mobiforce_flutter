import 'package:mobiforce_flutter/data/models/contractor_model.dart';
import 'package:mobiforce_flutter/data/models/phone_model.dart';
import 'package:mobiforce_flutter/data/models/taskfield_model.dart';
import 'package:mobiforce_flutter/data/models/tasksfields_model.dart';
import 'package:mobiforce_flutter/data/models/tasksstatuses_model.dart';
import 'package:mobiforce_flutter/data/models/taskstatus_model.dart';
import 'package:mobiforce_flutter/data/models/template_model.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';

import 'employee_model.dart';

class TaskModel extends TaskEntity
{

  TaskModel({required isChanged,required id,required usn,required serverId,required name, status, contractor, address, statuses, checkList, propsList, author, employees,phones, template}): super(
      isChanged:isChanged,
      id:id,
      usn:usn,
      serverId:serverId,
      name:name,
      contractor:contractor,
      address:address,
      status:status,
      statuses:statuses,
      propsList:propsList,
      checkList:checkList,
      author:author,
      employees:employees,
      phones:phones,
      template: template,
  );

  Map<String, dynamic> toMap(){
    final map=Map<String, dynamic>();
    map['name'] = name;
    map['usn'] = usn;
    map['external_id'] = serverId;
    map['contractor'] = contractor?.id;
    map['address'] = address;
    map['status'] = status?.id;
    map['contractor'] = contractor?.id;
    map['author'] = author?.id;
    map['template'] = template?.id;
    return map;
  }
  Future<int> insertToDB(db) async {
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

    if(template != null)
    {
      template?.id = await template!.insertToDB(db);
    }

    if(author != null)
    {
      author?.id = await author!.insertToDB(db);
    }
    //else
    //  id=0;
    print ("INSERT Status id = $id");
    dynamic t = await db.insertTask(this);
    int taskId=t.id;
    print ("db id == ${t.id}");
    if(taskId==0){
      taskId = await db.updateTaskByServerId(this);
      print ("db id == ${taskId}");
    }
    if(employees != null)
    {
      await db.deleteAllTaskEmployees(taskId);
      await Future.forEach(employees!,(EmployeeModel element) async {
        print("employees Id = ${element.serverId}");
        //element.task = taskId;
        int employeeId = await element.insertToDB(db);
        if(employeeId>0){
          await db.addTaskEmployee(taskId,employeeId);
        }
      });
    }
    if(phones != null)
    {
      await db.deleteAllTaskPhones(taskId);
      await Future.forEach(phones!,(PhoneModel element) async {
        print("phones Id = ${element.serverId}");
        //element.task = taskId;
        element.taskId=taskId;
        int employeeId = await element.insertToDB(db);
        //if(employeeId>0){
        //  await db.addTaskEmployee(taskId,employeeId);
        //}
      });
    }
    if(statuses != null)
    {
      await Future.forEach(statuses!,(TasksStatusesModel element) async {
        print("status Id = ${element.serverId}");
        element.task = taskId;
        await element.insertToDB(db);
      });
    }
    else
      id=0;
    print("checkList = ${checkList.toString()}");
    if(checkList != null)
    {
      await Future.forEach(checkList!,(TasksFieldsModel element) async {
        print("TasksFieldsModel checkList Id = ${element.serverId}");
        element.task = taskId;
        await element.insertToDB(db);
        if (element.childrens!=null&&element.childrens!.length>0){
          await Future.forEach(element.childrens!,(TasksFieldsModel elementChildren) async {
            print("TasksFieldsModel checkList elementChildren Id = ${elementChildren.serverId}");
            elementChildren.task = taskId;
            await elementChildren.insertToDB(db);
          });
        }
      });
    }
    else
      id=0;
    if(propsList != null)
    {
      await Future.forEach(propsList!,(TasksFieldsModel element) async {
        print("TasksFieldsModel checkList Id = ${element.serverId}");
        element.task = taskId;
        await element.insertToDB(db);
        if (element.childrens!=null&&element.childrens!.length>0){
          await Future.forEach(element.childrens!,(TasksFieldsModel elementChildren) async {
            print("TasksFieldsModel checkList elementChildren Id = ${elementChildren.serverId}");
            elementChildren.task = taskId;
            await elementChildren.insertToDB(db);
          });
        }
      });
    }
    else
      id=0;

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

    return 0;
  }
  factory TaskModel.fromMap({
    required Map<String, dynamic> taskMap,
    required Map<String, dynamic> statusMap,
    List<Map<String, dynamic>> statusesMap = const [],
    List<Map<String, dynamic>> tasksFieldsMap = const [],
    List<Map<String, dynamic>> tasksFieldsSelectionValuesMap = const [],
  })
  {
   // id = map['id'];
   // externalId = map['externalId'];
   // name = map['name'];
    int fieldId=0;
    //List<TaskFieldModel> taskFieldList = [];
    Map<int, dynamic> taskFieldSelectionValuesMap = {};
    List<Map<String, dynamic>> taskFieldSelectionValues = [];
    tasksFieldsSelectionValuesMap.forEach((element) {
      if(element["id"]!=fieldId){
        //taskFieldMapList.add(taskFieldMap);
        taskFieldSelectionValuesMap[fieldId]=taskFieldSelectionValues;
        fieldId=element["id"];
        //taskFieldMap={"id":element["id"],"name":element["name"]};
        taskFieldSelectionValues=[];
      }
      if(element["value_id"]!=null){
        taskFieldSelectionValues.add({
          "id":element["value_id"],
          "sorting":element["value_sorting"],
          "external_id":element["value_external_id"],
          "name":element["value_name"]});
      }

    });
    if(fieldId!=0)
      taskFieldSelectionValuesMap[fieldId]=taskFieldSelectionValues;

    var fieldList=tasksFieldsMap.map((tasksField) => TasksFieldsModel.fromMap(tasksField,taskFieldSelectionValuesMap)).toList();

    print("statusMap = ${statusMap.toString()}");
    return TaskModel(
        id: taskMap['id'],
        isChanged:false,
        usn: taskMap['usn'],
        serverId: taskMap['external_id'],
        //  contractor: taskMap['contractor'],
        address: taskMap['address'],
        name: taskMap['name'],
        status:TaskStatusModel.fromMap(statusMap),
        statuses: statusesMap.map((tasksStatuses) => TasksStatusesModel.fromMap(tasksStatuses)).toList(),
        propsList: fieldList,
    );
  }
  factory TaskModel.fromJson(Map<String, dynamic> json)
  {
    //print('jsonjson ${json[0]} ');
    //return TaskModel(id:0,externalId: 0, name: "");
    print('json["task_statuses"] = ${json["task_statuses"]}');
    print("ok1");
    var propsList = (json["props"] as List).map((taskStatus) => TasksFieldsModel.fromJson(taskStatus,1)).toList();
    print("ok2");
    var checkList = (json["checklist"] as List).map((taskStatus) => TasksFieldsModel.fromJson(taskStatus,2)).toList();
    propsList.addAll(checkList);
    print("ok3 ${json["contractor"]} ${json["contractor"].runtimeType.toString()} ${json["contractor"].runtimeType.toString()=='_InternalLinkedHashMap<String, dynamic>'}");
    ContractorModel? contractor;
    return TaskModel(
        id: 0,
        isChanged:false,
        usn: json["usn"]??0,
        serverId: int.parse(json["id"]??0),
        name: json["name"]??"",
        contractor: json["contractor"].runtimeType.toString()=='_InternalLinkedHashMap<String, dynamic>'?ContractorModel.fromJson(json["contractor"]):null,
        address: json["address"]??"",
        status:TaskStatusModel.fromJson(json["task_status"]),
        propsList:propsList,
        statuses:(json["task_statuses"] as List).map((taskStatus) => TasksStatusesModel.fromJson(taskStatus)).toList(),
        author:json["author"].runtimeType.toString()=='_InternalLinkedHashMap<String, dynamic>'?EmployeeModel.fromJson(json["author"]):null,
        employees:json["employee"].runtimeType.toString()=='_InternalLinkedHashMap<String, dynamic>'?[EmployeeModel.fromJson(json["employee"])]:null,
        template:json["tasktemplate"].runtimeType.toString()=='_InternalLinkedHashMap<String, dynamic>'?TemplateModel.fromJson(json["tasktemplate"]):null,
        phones:(json["phone"] as List).map((phone) => PhoneModel.fromJson(phone)).toList(),
      //(json["emplo"] as List).map((taskStatus) => TasksStatusesModel.fromJson(taskStatus)).toList(),
    );
  }
  /*fromMap(Map<String, dynamic> map)
  {
    id = map['id'];
    name = map['name'];
  }*/

}