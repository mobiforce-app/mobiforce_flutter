import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/data/models/phone_model.dart';
import 'package:mobiforce_flutter/domain/entity/employee_entity.dart';
import 'package:mobiforce_flutter/domain/entity/person_entity.dart';
import 'package:mobiforce_flutter/domain/entity/phone_entity.dart';
import 'package:mobiforce_flutter/domain/entity/resolution_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';
import 'package:mobiforce_flutter/domain/entity/template_entity.dart';

class PersonModel extends PersonEntity
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

  PersonModel({required id,required usn,serverId,required name, taskId, phones, temp, contractorPersonServerId}): super(
      id:id,
      usn:usn,
      serverId:serverId,
      name:name,
      taskId:taskId,
      phones:phones,
      temp: temp,
      contractorPersonServerId:contractorPersonServerId,
  );
  Map<String, dynamic> toJson(){
    final map=Map<String, dynamic>();
    if(serverId!=null&&serverId!=0)
        map["id"]=serverId;
    map["contractorPerson"]=contractorPersonServerId;
    map["name"]=name;
    if(phones!=null)
    {
      List<Map<String, dynamic>> phonesJSON=[];
      phones?.forEach((PhoneModel element) {
        phonesJSON.add(element.toJson());
      });
      map["phone"]=phonesJSON;
    }

    return map;
  }
  Map<String, dynamic> toMap(){
    final map=Map<String, dynamic>();
    map['name'] = name;
    map['temp'] = temp==true?1:0;
    map['external_id'] = serverId;
    map['contractor_person_external_id'] = contractorPersonServerId;
    map['task'] = taskId;
    return map;
  }
  Future<int> insertToDB(DBProvider db) async {
    PersonModel t = await db.insertPerson(this);
    if(t.id==0&&t.serverId!=null){
      t = await db.updatePersonByServerId(this);
      //print ("db id == ${t.toString()}");
    }

    if(phones != null&&t.id>0)
    {
      //print("phonenotnull");
      await db.deleteAllPersonPhones(t.id);
      await Future.forEach(phones!,(PhoneModel element) async {
        //print("phones Id = ${element.serverId}");
        //element.task = taskId;
        element.personId=t.id;
        element.taskId=t.taskId;
        int phoneId = await element.insertToDB(db);
        element.id = phoneId;
        //print("phonenotnull $phoneId");

        //if(employeeId>0){
        //  await db.addTaskEmployee(taskId,employeeId);
        //}
      });
    }

    //print ("employee db id == ${t.id}");
    return t.id;
  }
  factory PersonModel.fromMap(Map<String, dynamic> map)
  {
   // id = map['id'];
   // externalId = map['externalId'];
   // name = map['name'];

    return PersonModel(
        id: map['id'],
        taskId: map['task']??0,
        usn: map['usn']??0,
        serverId: map['external_id']??0,
        name: map['name'],
        temp: map['temp']==1?true:false,
        contractorPersonServerId: map['contractor_person_external_id'],
        phones: (map["phone"] as List).map((phone) => PhoneModel.fromMap(phone)).toList(),
    );
  }
  factory PersonModel.fromJson(Map<String, dynamic> json)
  {
    //print('employeejsonjson ${json} ');
    print('PersonModeljsonjson ${json} ');

    //return TaskModel(id:0,externalId: 0, name: "");
    return PersonModel(
        id: 0,
        usn: int.parse(json["usn"]??"0"),
        serverId: int.parse(json["id"]??"0"),
        name: json["name"]??"",
        contractorPersonServerId:int.parse(json["contractorPerson"]??"0"),
        phones:(json["phone"] as List).map((phone) => PhoneModel.fromJson(phone)).toList(),
    );
  }
  /*fromMap(Map<String, dynamic> map)
  {
    id = map['id'];
    name = map['name'];
  }*/

}