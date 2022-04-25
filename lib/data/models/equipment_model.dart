import 'dart:developer';

import 'package:mobiforce_flutter/core/db/database.dart';
import 'package:mobiforce_flutter/data/models/contractor_model.dart';
import 'package:mobiforce_flutter/domain/entity/employee_entity.dart';
import 'package:mobiforce_flutter/domain/entity/equipment_entity.dart';
import 'package:mobiforce_flutter/domain/entity/resolution_entity.dart';
import 'package:mobiforce_flutter/domain/entity/task_entity.dart';

class EquipmentModel extends EquipmentEntity
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

  EquipmentModel({required id,required usn,required serverId,required name, contractor,}): super(
      id:id,
      usn:usn,
      serverId:serverId,
      name:name,
      contractor:contractor,
      //webAuth:webAuth,
      //mobileAuth:mobileAuth
      //client:client,
      //address:address
  );

  Map<String, dynamic> toMap(){
    final map=Map<String, dynamic>();
    map['name'] = name;
    map['external_id'] = serverId;
    //map['mobile_auth'] = mobileAuth?1:0;
    //map['web_auth'] = webAuth?1:0;
    //map['client'] = client;
    //map['address'] = address;
    print("set equipment ${map.toString()}");
    return map;
  }
  Map<String, dynamic> toJson(){
    final map=Map<String, dynamic>();
    map["name"]=name;
    map["id"]=serverId;
    map["contractor"]=contractor?.toJson();
    return map;
  }
  Future<int> insertToDB(DBProvider db) async {
    Timeline.startSync('Employee Insert To DB');
    print("insert equipment ${this.toJson().toString()}");
    dynamic t = await db.insertEquipment(this);
    if(t.id==0)
    {
      print("update equipment ${this.toJson().toString()}");
      t = await db.updateEquipmentByServerId(this);
      print("update equipment ${t.toJson().toString()} ok");
      //print ("db id == ${t.toString()}");
    }

    //print ("employee db id == ${t.id}");
    Timeline.finishSync();
    return t.id;
  }
  factory EquipmentModel.fromMap(Map<String, dynamic> map)
  {
   // id = map['id'];
   // externalId = map['externalId'];
   // name = map['name'];
    return EquipmentModel(
        id: map['id'],
        usn: map['usn']??0,
        serverId: map['external_id'],
        //mobileAuth: map['mobile_auth']==1?true:false,
        //webAuth: map['web_auth']==1?true:false,
        //client: map['client'],
        //address: map['address'],
        name: map['name']
    );
  }
  factory EquipmentModel.fromJson(Map<String, dynamic> json)
  {
    print('equipmentjsonjson ${json} ');
    //return TaskModel(id:0,externalId: 0, name: "");
    return EquipmentModel(
        id: 0,
        usn: json["usn"]??0,
        serverId: int.parse(json["id"]??0),
        name: json["description"]??"",
       contractor: json["contractor"].runtimeType.toString()=='_InternalLinkedHashMap<String, dynamic>'?ContractorModel.fromJson(json["contractor"]):null,
       // webAuth: json["webAuth"]??false,
       // mobileAuth: json["mobileAuth"]??false,
        //client: json["client"]??"",
        //address: json["address"]??""
    );
  }
  /*fromMap(Map<String, dynamic> map)
  {
    id = map['id'];
    name = map['name'];
  }*/

}